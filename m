From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Sun, 18 Oct 2015 22:19:58 -0700
Message-ID: <20151018221958.1b7b9d0d@xeon-e3>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36312 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbJSFTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:19:48 -0400
Received: by pacfv9 with SMTP id fv9so83370498pac.3
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 22:19:47 -0700 (PDT)
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015 00:21:44 -0400
Michael Chan <mchan@broadcom.com> wrote:

> +static bool bnxt_vf_pciid(int idx)
> +{
> +	if (idx == BCM57304_VF || idx == BCM57404_VF)
> +		return true;
> +	return false;
> +}
> +

I prefer just returning result of logical operation
rather than adding unnecessary if statement.
And never use (signed) int when unsigned is the real
data type. Also avoid any unnecessary expansion of 16 bit
value.

static bool bnxt_vf_pciid(u16 idx)
{
	return (idx == BCM57304_VF || idx == BCM57404_VF);
}
