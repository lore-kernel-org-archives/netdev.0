From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [RFC PATCH 02/12] On Tue, 23 Sep 2008, David Miller wrote:
Date: Sat, 4 Oct 2008 18:24:10 -0700
Message-ID: <4807377b0810041824u5ea472d1q4cf5ff606bd23a11@mail.gmail.com>
References: <20080930030825.22950.18891.stgit@jbrandeb-bw.jf.intel.com>
	 <200810021523.45884.jbarnes@virtuousgeek.org>
	 <20081003.134634.240211201.davem@davemloft.net>
	 <200810031429.22598.jbarnes@virtuousgeek.org>
	 <alpine.LNX.1.10.0810032338140.26779@jikos.suse.cz>
	 <4807377b0810031628x43f79eferdbb9c9c264a5816e@mail.gmail.com>
	 <alpine.LNX.1.10.0810041219130.26779@jikos.suse.cz>
	 <alpine.LFD.2.00.0810041236250.4404@apollo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jiri Kosina" <jkosina@suse.cz>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"David Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kkeil@suse.de, agospoda@redhat.com, arjan@linux.intel.com,
	david.graham@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, chris.jones@canonical.com,
	tim.gardner@canonical.com, airlied@gmail.com,
	"Olaf Kirch" <okir@suse.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:46006 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbYJEBYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 21:24:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2310478rvb.1
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 18:24:10 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.0810041236250.4404@apollo>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 4, 2008 at 4:02 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Sat, 4 Oct 2008, Jiri Kosina wrote:
>> On Fri, 3 Oct 2008, Jesse Brandeburg wrote:
>> > Our experience is different.  We are also testing with the "protection
>> > patch" reverted.
>> > We see that the problem specifically comes and goes when
>> > removing/adding the use of set_memory_ro/set_memory_rw to the driver.
>>
>> But if this patch (which is an obvious workaround, compared to the other
>> patches which fix real bugs, right?) would be catching some malicious
>> accessess to the mapped EEPROM, there should be stacktraces present in the
>> kernel log, right?

yes, but I think it is just changing timing, i don't see any backtraces either.

> Exactly. The access to a ro region results in a fault. I have nowhere
> seen that trigger, but I can reproduce the trylock() WARN_ON, which
> confirms that there is concurrent access to the NVRAM registers. The
> backtrace pattern is similar to the one you have seen.

are you still getting WARN_ON *with* all the mutex based fixes already applied?

with the mutex patches in place (without protection patch) we are
still reproducing the issue, until we apply the set_memory_ro patch.
I had no luck on friday setting a hardware breakpoint on memory access
with kgdb to catch the writer with a breakpoint.
