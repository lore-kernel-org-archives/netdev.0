From: Samuel Tardieu <sam@rfc1149.net>
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: 03 Oct 2006 17:58:31 +0200
Message-ID: <2006-10-03-17-58-31+trackit+sam@rfc1149.net>
References: <20060928014623.ccc9b885.akpm@osdl.org> <200609290319.k8T3JOwS005455@turing-police.cc.vt.edu> <20060928202931.dc324339.akpm@osdl.org> <200609291519.k8TFJfvw004256@turing-police.cc.vt.edu> <20060929124558.33ef6c75.akpm@osdl.org> <200609300001.k8U01sPI004389@turing-police.cc.vt.edu> <20060929182008.fee2a229.akpm@osdl.org> <20061002175245.GA14744@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: Valdis.Kletnieks@vt.edu,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anyanka.rfc1149.net ([81.56.47.149]:57067 "EHLO
	mail2.rfc1149.net") by vger.kernel.org with ESMTP id S1030239AbWJCP6i
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:58:38 -0400
To: jt@hpl.hp.com
In-Reply-To: <20061002175245.GA14744@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Jean" == Jean Tourrilhes <jt@hpl.hp.com> writes:

Jean> @@ -2500,9 +2501,9 @@ static int orinoco_hw_get_essid(struct o
Jean>  	len = le16_to_cpu(essidbuf.len);
Jean>  	BUG_ON(len > IW_ESSID_MAX_SIZE);
Jean>  
Jean> -	memset(buf, 0, IW_ESSID_MAX_SIZE+1);
Jean> +	memset(buf, 0, IW_ESSID_MAX_SIZE);
Jean>  	memcpy(buf, p, len);
Jean> -	buf[len] = '\0';
Jean> +	err = len;

Jean,

something bugs me here:

  - either buf is supposed to be a nul-terminated string, in which
    case if p is IW_ESSID_MAX_SIZE long there may be a bug (no '\0' at
    the end of buf)

  - either buf is not-supposed to be nul-terminated and the length
    value will always be used, in which case the memset() looks
    useless

I suggest that you revert the memset() to IW_ESSID_MAX_SIZE+1 so that
the last byte is cleared as well. Or am I missing something?

 Sam
-- 
Samuel Tardieu -- sam@rfc1149.net -- http://www.rfc1149.net/

