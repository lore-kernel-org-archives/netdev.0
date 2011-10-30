From: Tejun Heo <tj@kernel.org>
Subject: Re: hiberante hangs TCP Re: [EXAMPLE CODE] Parasite
 thread injection and TCP connection hijacking
Date: Sun, 30 Oct 2011 13:16:18 -0700
Message-ID: <20111030201618.GA7696@google.com>
References: <20110806121247.GC23937@htj.dyndns.org>
	<20111030044821.GA23741@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Fries <david@fries.net>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111030044821.GA23741@spacedout.fries.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

(cc'ing Rafael and linux-pm)

On Sat, Oct 29, 2011 at 11:48:21PM -0500, David Fries wrote:
> I saw the write up on this on lwn.net, pretty creative by the way, and
> it got me thinking about a different checkpoint/restart problem I've
> been running into.  Specifically in hibernating to disk.  In the
> hibernate case active TCP connections hang after resuming, while an
> idle TCP connection will continue after the system is back up.  My
> observation is the kernel checkpoints itself to memory, enables
> devices, writes out that checkpoint image to storage, then powers off.
> The problem is if TCP packets are received while writing to storage,
> the kernel will continue to queue and ack those TCP packets, but the
> running kernel and it's network state is shortly lost.  When the
> computer resumes, those TCP byte sequences hang the TCP connection for
> an extended period of time while the resumed computer refuses to
> acknowledge the data that was received after checkpointing and the now
> running kernel knew nothing about, and the other computer tries in
> vain to resend any data that hadn't yet been acknowledged, which is
> always after the data that was lost, until one of them eventually
> gives up.
> 
> I've been wondering if it was safe or possible to leave any network
> interfaces down after the checkpoint, or what the right solution would
> be.  I didn't think marking every TCP connection with a ZOMBIE_KERNEL
> bit just after the kernel checkpoint (for the kernel is walking dead
> and won't remember anything that happens), and then prevent any TCP
> acks from being sent for those connections would be the right
> solution.  I've taken to unplugging the physical lan cable,
> hibernating to disk, and plugging it back in after the system is down,
> to avoid the problem.  Any ideas?

Hmmm... sounds like taking down network interfaces before starting
hibernation sequence should be enough, which shouldn't be too
difficult to implement from userland.  Rafael, what do you think?

Thanks.

-- 
tejun
