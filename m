From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: 4.11-rc1 regression: e1000e "BUG at drivers/pci/msi.c" on unplugged suspend+resume
Date: Mon, 06 Mar 2017 13:03:16 +0100
Message-ID: <8760jmipdn.fsf@miraculix.mork.no>
References: <87bmten48r.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, khalidm <khalidm@cisco.com>,
        David Singleton <davsingl@cisco.com>,
        Aaron Brown <aaron.f.brown@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43301 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753027AbdCFMDi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 07:03:38 -0500
In-Reply-To: <87bmten48r.fsf@miraculix.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of
        "Mon, 06 Mar 2017 10:28:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> This is new with v4.11-rc1, so I strongly suspect commit 7e54d9d063fa
> ("e1000e: driver trying to free already-free irq"), which looks more
> than suspicious in this context.  Haven't had time to test a revert
> yet.  Just wanted to give an advance warning in case this isn't known.

Now tested.  I can confirm that reverting commit 7e54d9d063fa ("e1000e:
driver trying to free already-free irq") fixes the issue.

Further testing also shows that "netif running" is irrelevant.  The BUG
happens consistently on revery system resume, regardless of the e1000e
link state.  Which sort of indicates that this change to the driver's
freeze callback wasn't tested with system suspend.  Which seems.... odd?

Well, whatever.  Please revert commit 7e54d9d063fa.



Bj=C3=B8rn
