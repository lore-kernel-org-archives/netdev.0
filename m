From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH] Allow renaming of network interfaces that are up.
Date: Wed, 21 Oct 2009 07:50:30 +0100
Message-ID: <874optb5qh.fsf@spindle.srvr.nix>
References: <87zl7rp1jy.fsf@spindle.srvr.nix> <1255723078.14249.16.camel@calx>
	<87k4yup9bd.fsf@spindle.srvr.nix> <87vdi9ew1h.fsf_-_@spindle.srvr.nix>
	<20091021103846.2f985ea1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752760AbZJUGuj@vger.kernel.org>
In-Reply-To: <20091021103846.2f985ea1@s6510> (Stephen Hemminger's message of "Wed, 21 Oct 2009 10:38:46 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cc:s adjusted, thanks davem]

On 21 Oct 2009, Stephen Hemminger said:

> On Tue, 20 Oct 2009 19:54:02 +0100
> Nix <nix@esperi.org.uk> wrote:
[...]
>> This makes it much easier to use things like netconsole which bring up a
>> network interface before userspace has started: presently these will cause
>> interface renamings to fail, breaking any userspace that relies on renaming
>> devices to avoid reliance on the potentially-unstable kernel-assigned name.
[...]
> This breaks quagga and other applications that track renames.

So it's only userspace that's the problem? We have a choice of breaking
apps that assume that only downed interfaces can be renamed, and thus
breaking routing while the system is running, or breaking userspaces
that assume that they can rename interfaces, and thus breaking routing
at bootup when netconsole is on? Great :/

(How many systems run things that track renames? Is this, ew, a reason
to make this constraint configurable, maybe even at runtime, so you
could start with interfaces renameable and then lock them down once
static route assignment is up, just before you fire up quagga?)
