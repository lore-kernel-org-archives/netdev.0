From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 patch set
Date: Sat, 24 Jan 2004 00:32:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124003216.A24000@electric-eye.fr.zoreil.com>
References: <1074876326.5510.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dpollock@acm.org
Content-Disposition: inline
In-Reply-To: <1074876326.5510.5.camel@localhost>; from douglas.pollock@magma.ca on Fri, Jan 23, 2004 at 11:45:26AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Douglas Pollock <douglas.pollock@magma.ca> :
[...]
> Let me know if you would like me to test something in particular.

Yes.

I assume it is a bit premature to try to run r8169 with HT SMP, acpi and
nvidia binary module at the same time.

So I would suggest to build a kernel with both SMP and acpi disabled.
Then boot in single user mode or anything similar which avoids the nvidia
module to be loaded at all before the test*. I'd welcome two things:
- behavior with a simple 'ping -c 144 remote_host'
  No load, it just walks twice the Rx/Tx rings.
- behavior under load. Use the tool of your choice. No need to reboot
  after the aforementioned test if the system is still sane.

If you can spend some time on it, a report between each patch would be nice:
1)   r8169-tx-index-overflow.patch

2)   r8169-tx-index-overflow.patch
   + r8169-dma-api-tx.patch

3)   r8169-tx-index-overflow.patch
   + r8169-dma-api-tx.patch
   + r8169-dma-api-rx-buffers.patch

etc, until:
- the 16 rounds of patches/tests are exhausted ;
- you are bored :o)

The 4 most recent patches (-getstats/-addr-high/-ethtool/-static) can wait.



[*] Why ?
1) there is a ~200x ratio in size from r8169 to nvidia module
   r8169                   9728  0 
   nvidia               1701612  8 
2) because.

--
Ueimor
