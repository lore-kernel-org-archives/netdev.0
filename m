From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: Tue, 3 Oct 2006 10:07:51 -0700
Message-ID: <20061003170751.GG17252@bougret.hpl.hp.com>
References: <200609290319.k8T3JOwS005455@turing-police.cc.vt.edu> <20060928202931.dc324339.akpm@osdl.org> <200609291519.k8TFJfvw004256@turing-police.cc.vt.edu> <20060929124558.33ef6c75.akpm@osdl.org> <200609300001.k8U01sPI004389@turing-police.cc.vt.edu> <20060929182008.fee2a229.akpm@osdl.org> <20061002175245.GA14744@bougret.hpl.hp.com> <2006-10-03-17-58-31+trackit+sam@rfc1149.net> <20061003163415.GA17252@bougret.hpl.hp.com> <2006-10-03-18-45-35+trackit+sam@rfc1149.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:58612 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1030336AbWJCRIY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 13:08:24 -0400
To: Samuel Tardieu <sam@rfc1149.net>
Content-Disposition: inline
In-Reply-To: <2006-10-03-18-45-35+trackit+sam@rfc1149.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 06:45:35PM +0200, Samuel Tardieu wrote:
> On  3/10, Jean Tourrilhes wrote:
> 
> | > I suggest that you revert the memset() to IW_ESSID_MAX_SIZE+1 so that
> | > the last byte is cleared as well. Or am I missing something?
> | 
> | No, that would bring back the slab/memory overflow we are
> | trying to get rid of.
> 
> Then I am puzzled by the function declaration:
> 
> static int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
>                                 char buf[IW_ESSID_MAX_SIZE+1])
> 
> Do you mean that this function is called with a buf parameter which
> doesn't have the expected size? (as far as the function declaration is
> concerned) Shouldn't the declaration be changed to
> 
> static int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
>                                 char buf[IW_ESSID_MAX_SIZE])
> 
> then to reflect the reality? (it won't change the code but would be
> clearer from a documentation point of view)

	Yep, that one is a bug.
	Thanks !

>  Sam

	Jean
