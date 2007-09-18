From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Tue, 18 Sep 2007 15:17:37 -0400
Message-ID: <9e4733910709181217v417438s85bb9e6b4ad4b475@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
	 <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
	 <20070918151622.GD32628@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: "Domen Puncer" <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:28974 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbXIRTRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:17:38 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1682540rvb
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 12:17:37 -0700 (PDT)
In-Reply-To: <20070918151622.GD32628@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/18/07, Domen Puncer <domen@coderock.org> wrote:
> More testing and getting it to work properly on Phytec pcm030 would
> be great.

I compiled it as a module:
  CC [M]  drivers/net/fec_mpc52xx/fec.o
drivers/net/fec_mpc52xx/fec.c:613: warning: 'mpc52xx_fec_mac_setup'
defined but not used

This code needs to be enclosed in "#ifndef MODULE". But why aren't you
using module_param() to make a string parameter and then copy it into
mpc52xx_fec_mac_addr[] if the parameter is not null?

If it is a module param you need to use
fec_mpc52xx_phy.mpc52xx-mac="xxxx" instead of just mpc52xx-mac. The
way it is not you can't use mpc52xx-mac when built as a module.

static int __init mpc52xx_fec_mac_setup(char *mac_address)
{
        int i;
        u64 val64;

        val64 = simple_strtoull(mac_address, NULL, 16);

        for (i = 0; i < 6; i++)
                mpc52xx_fec_mac_addr[5-i] = val64 >> (i*8);

        return 0;
}

__setup("mpc52xx-mac=", mpc52xx_fec_mac_setup);



-- 
Jon Smirl
jonsmirl@gmail.com
