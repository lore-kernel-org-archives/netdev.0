From: "Raghavendra Koushik" <raghavendra.koushik@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 7/8] S2io: NAPI fix
Date: Thu, 14 Oct 2004 09:44:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410141644.i9EGi839024175@guinness.s2io.com>
References: <416E948B.5050701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <leonid.grossman@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>, <ravinandan.arakali@s2io.com>
In-Reply-To: <416E948B.5050701@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

My comments inline.

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Thursday, October 14, 2004 8:00 AM
> To: ravinandan.arakali@s2io.com
> Cc: 'Francois Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com;
> raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
> Subject: Re: [PATCH 2.6.9-rc2 7/8] S2io: NAPI fix
> 
> Comments on patch #7:
> 
> 1) Can you prove that put_lock is really necessary, and not covered by
> other methods of synchronization?  Typically the preferred model is that
> your RX process requires _no_ spinlocks, and instead you use the net
> stack API to ensure when your RX process is, and is not, running.
> 
<KSK>
	Lets say, CPU0 after processing s2io_isr, schedules s2io_tasklet.
The tasklet in turn calls fill_rx_buffer which will replenish skbs into Rx
descriptors and start modifying the put index of the Rx ring, at the same
time if there is another Rx interrupt being processed (rx_intr_handler) on
CPU1, then it will try to read put index of the ring which can result in
synchronization problem. So I created this new variable put_pos to track the
absolute value of the put index and make sure all its accesses are between
spin locks. The same problem cannot happen if NAPI is used since the
s2io_poll and fill_rx_buffer calls are serialized.

-Koushik

> otherwise, no objections to this patch
