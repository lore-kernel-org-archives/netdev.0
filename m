From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] mlxsw: spectrum: Add FDB lock to prevent session
 interleaving
Date: Mon, 11 Jan 2016 09:41:36 +0100
Message-ID: <20160111084135.GA2246@nanopsycho.orion>
References: <1452414736-3571-1-git-send-email-jiri@resnulli.us>
 <20160111.002103.979291218776108297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33727 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbcAKIlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 03:41:40 -0500
Received: by mail-wm0-f68.google.com with SMTP id u188so25156952wmu.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 00:41:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160111.002103.979291218776108297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 11, 2016 at 06:21:03AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sun, 10 Jan 2016 09:32:16 +0100
>
>> From: Ido Schimmel <idosch@mellanox.com>
>> 
>> Dumping the FDB (invoked with a process context) or handling FDB
>> notifications (polled periodicly in delayed work) might each entail
>> multiple EMAD transcations due to the number of entries.
>> 
>> While we only allow one EMAD transaction at a time, there is nothing
>> stopping the dump and notification processing sessions from
>> interleaving. However, this is forbidden by the hardware, so we need to
>> make sure only one of these sessions can run at a time.
>> 
>> Solve this by adding a mutex ('fdb_lock'), as both kernel threads can
>> sleep while waiting for the response EMAD.
>> 
>> Fixes: 56ade8fe3f ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>Jiri, I noticed you submitted both a net and a net-next variant of
>this same fix.  Please don't ever do that.
>
>it's easiest if I just apply the 'net' variant and handle the merge
>issues when I pull 'net' into 'net-next', so that how I'm going to
>handle this change.

Okay. I just wanted to help since the net-next patch differs. Thanks!
