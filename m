From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Wed, 29 May 2013 16:55:32 +0300
Message-ID: <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
	<20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
	<CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
	<20130525151347.GB25744@lintop.rgmadvisors.com>
	<20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:57078 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759565Ab3E2Nzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 09:55:33 -0400
Received: by mail-qc0-f182.google.com with SMTP id n1so4761414qcw.13
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 06:55:32 -0700 (PDT)
In-Reply-To: <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 11:15 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> Naturally I was wrong and we set more than the above non-default
> values.  We additionally set high_rate_steer=1 on mlx4_core. As
> you may know this parameter isn't currently available in the upstream
> driver, so I've been carrying the following patch in my 3.4 and 3.10 trees:

[...]

> I've confirmed that with the above high_rate_steer patch and
> high_rate_steer=1 I receive data on 3.10.0-rc3 and with
> high_rate_steer=0 I only receive data on a small number of multicast
> addresses.  With 3.4 and the same patch I receive data in both cases.

[...]

Shawn, so end-in mind you want the NIC steering mode to be DMFS
(Device Managed Flow Steering) e.g for the processes bypassing the
kernel, correct? since the NIC steering mode is global, you will not
be able to use that non-upstream patch moving forward. So we need to
debug/bisect why without the patch (what you call high_rate_steer=0)
you don't get data on all groups. Can you bisect that on a single
node, e.g set the rest of the environment with 3.4 that works, and on
a given node see what is the commit that breaks that?

Or.
