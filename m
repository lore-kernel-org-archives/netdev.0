From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 00/10] switchdev: transaction item queue and cleanup
Date: Tue, 22 Sep 2015 09:22:23 -0700
Message-ID: <CAE4R7bAVGGKQsGu5MyWMvZQCcH_FkxGT96ivHj9RArsua4N32Q@mail.gmail.com>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35730 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933729AbbIVQWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:22:44 -0400
Received: by oiww128 with SMTP id w128so8410363oiw.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:22:42 -0700 (PDT)
In-Reply-To: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 6:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Jiri Pirko (10):
>   switchdev: rename "trans" to "trans_ph".
>   switchdev: introduce transaction item queue for attr_set and obj_add
>   switchdev: move transaction phase enum under transaction structure
>   switchdev: add switchdev_trans_ph_prepare/commit helpers
>   rocker: push struct switchdev_trans down through rocker code
>   rocker: use switchdev transaction queue for allocated memory
>   switchdev: remove "NONE" transaction phase
>   switchdev: remove "ABORT" transaction phase
>   dsa: use prepare/commit switchdev transaction helpers
>   switchdev: reduce transaction phase enum down to a boolean
>
>  drivers/net/ethernet/rocker/rocker.c | 311 +++++++++++++++--------------------
>  include/net/switchdev.h              |  40 +++--
>  net/dsa/slave.c                      |  31 ++--
>  net/switchdev/switchdev.c            |  99 ++++++++---
>  4 files changed, 252 insertions(+), 229 deletions(-)

I like this version much better!  Thank you for making the
adjustments.  My main concern about easily opting-out of prepare phase
is gone.  And I appreciate that you moved trans * as arg to attr_set
and obj_add.

Would you add a write-up in switchdev.txt about prepare-commit model
and how to use the transaction object?  Add it to this patchset, if
you can.

What testing have you done?  I'll do testing today on my bench and
report back, but I kind of want to know what to expect.

Give a day or two for testing and review.
