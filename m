From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 09/15] i40e: use priv flags to control packet split
Date: Sat, 5 Dec 2015 23:25:18 +0200
Message-ID: <CAJ3xEMi7=-LgxapNQM2YX26nxqA9gCceMX95wOEGn-WztsQYbg@mail.gmail.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1449149160-105219-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36790 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbLEVZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 16:25:19 -0500
Received: by iofh3 with SMTP id h3so148854943iof.3
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 13:25:18 -0800 (PST)
In-Reply-To: <1449149160-105219-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 3:25 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> Ethtool priv flags implementation to enable or disable packet split, which
> is a hardware feature that inspects headers and will put headers in a
> separate DMA buffer from the payload data.  The driver was automatically
> choosing to enable packet split in some cases and this gives the user the
> ability to turn it off/on explicitly.
>
> to query state:
> ethtool --show-priv-flags ethx
>
> to enable:
> ethtool --set-priv-flags ethx packet-split on
> to disable:
> ethtool --set-priv-flags ethx packet-split off
>
> Why would anyone want this?
>         Because some environments benefit from header/data split in the receive
>         buffer, and the driver defaults to one or the other depending on
>         environment/kernel parameters.
>
> Why didn't you implement a generic ethtool control for this feature?
>         Because Intel hardware is the only hardware that supports header/data
>         split.


Hi Jesse,

HDS is a generic feature,and even if you think only Intel hardware is
the only hardware that supports that, you have multiple drivers..
right? why not go the right way of adding new netdev feature and
enable/disable it through the conventional ethtool feature on/off
directive?

Or.
