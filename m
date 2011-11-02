From: MyungJoo Ham <myungjoo.ham@gmail.com>
Subject: Re: hiberante hangs TCP Re: [EXAMPLE CODE] Parasite
 thread injection and TCP connection hijacking
Date: Wed, 2 Nov 2011 18:44:31 +0900
Message-ID: <CAJ0PZbSRX6Rqn5NnnMkVGrPovtSuc2NWasysOYnjr3j9rON1VQ@mail.gmail.com>
References: <20110806121247.GC23937@htj.dyndns.org>
	<20111030044821.GA23741@spacedout.fries.net>
	<20111030201618.GA7696@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	David Fries <david@fries.net>, linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <20111030201618.GA7696@google.com>
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

On Mon, Oct 31, 2011 at 5:16 AM, Tejun Heo <tj@kernel.org> wrote:
> (cc'ing Rafael and linux-pm)
>
> On Sat, Oct 29, 2011 at 11:48:21PM -0500, David Fries wrote:
>> I saw the write up on this on lwn.net, pretty creative by the way, and
>> it got me thinking about a different checkpoint/restart problem I've
>> been running into. =A0Specifically in hibernating to disk. =A0In the
>> hibernate case active TCP connections hang after resuming, while an
>> idle TCP connection will continue after the system is back up. =A0My
>> observation is the kernel checkpoints itself to memory, enables
>> devices, writes out that checkpoint image to storage, then powers off.
>> The problem is if TCP packets are received while writing to storage,
>> the kernel will continue to queue and ack those TCP packets, but the
>> running kernel and it's network state is shortly lost. =A0When the
>> computer resumes, those TCP byte sequences hang the TCP connection for
>> an extended period of time while the resumed computer refuses to
>> acknowledge the data that was received after checkpointing and the now
>> running kernel knew nothing about, and the other computer tries in
>> vain to resend any data that hadn't yet been acknowledged, which is
>> always after the data that was lost, until one of them eventually
>> gives up.
>>
>> I've been wondering if it was safe or possible to leave any network
>> interfaces down after the checkpoint, or what the right solution would
>> be. =A0I didn't think marking every TCP connection with a ZOMBIE_KERNEL
>> bit just after the kernel checkpoint (for the kernel is walking dead
>> and won't remember anything that happens), and then prevent any TCP
>> acks from being sent for those connections would be the right
>> solution. =A0I've taken to unplugging the physical lan cable,
>> hibernating to disk, and plugging it back in after the system is down,
>> to avoid the problem. =A0Any ideas?
>
> Hmmm... sounds like taking down network interfaces before starting
> hibernation sequence should be enough, which shouldn't be too
> difficult to implement from userland. =A0Rafael, what do you think?
>
> Thanks.

Um... it seems that the "thaw" callbacks of network interfaces or TCP
should do something on this.

Probably, the "thaw" callbacks should make sure that the TCP
connections are closed?



Cheers,
MyungJoo


>
> --
> tejun
> _______________________________________________
> linux-pm mailing list
> linux-pm@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/linux-pm
>



-- =

MyungJoo Ham, Ph.D.
Mobile Software Platform Lab, DMC Business, Samsung Electronics
