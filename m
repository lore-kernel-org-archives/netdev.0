From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 0/3] ethtool: support for forward error
 correction mode setting on a link
Date: Thu, 27 Jul 2017 19:33:20 -0700
Message-ID: <20170727193320.308e86c3@cakuba.netronome.com>
References: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com,
        netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, galp@mellanox.com, andrew@lunn.ch,
        manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:42868 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751738AbdG1Cdc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 22:33:32 -0400
In-Reply-To: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jul 2017 16:47:25 -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Forward Error Correction (FEC) modes i.e Base-R
> and Reed-Solomon modes are introduced in 25G/40G/100G standards
> for providing good BER at high speeds. Various networking devices
> which support 25G/40G/100G provides ability to manage supported FEC
> modes and the lack of FEC encoding control and reporting today is a
> source for interoperability issues for many vendors.
> FEC capability as well as specific FEC mode i.e. Base-R
> or RS modes can be requested or advertised through bits D44:47 of base link
> codeword.
> 
> This patch set intends to provide option under ethtool to manage and
> report FEC encoding settings for networking devices as per IEEE 802.3
> bj, bm and by specs.
> 
> v2 :
>         - minor patch format fixes and typos pointed out by Andrew
>         - there was a pending discussion on the use of 'auto' vs
>           'automatic' for fec settings. I have left it as 'auto'
>           because in most cases today auto is used in place of
>           automatic to represent automatically generated values.
>           We use it in other networking config too. I would prefer
>           leaving it as auto.

On the subject of resetting the values when module is replugged I
assume what was previously described remains:
 - we always allow users to set the FEC regardless of the module type;
 - if user set an incorrect FEC for the module type (or module gets
   swapped) the link will be administratively taken down by either
   the driver or FW.

Is that correct?  Am I misremembering?
