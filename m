From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Tue, 11 Dec 2012 10:22:36 -0800
Message-ID: <87txrs30ur.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com>
	<20121207010355.c809b3f7.akpm@linux-foundation.org>
	<20121207142331.GC4004@sergelap> <50C1FD9D.5020703@parallels.com>
	<87r4n1buuw.fsf@xmission.com> <50C6EDF0.5060108@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50C6EDF0.5060108-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Tue, 11 Dec 2012 12:25:20 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> On 12/07/2012 10:05 PM, Eric W. Biederman wrote:
>> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
>> 
>>> I keep asking myself if it isn't the case of forwarding to a container
>>> all messages printed in process context. That will obviously exclude all
>>> messages resulting from kthreads - that will always be in the initial
>>> namespace anyway, interrupts, etc. There is no harm, for instance, in
>>> delivering the same message twice: one to the container, and the other
>>> to the host system.
>> 
>> Except that there is harm in double printing.  One of the better
>> justifications for doing something with the kernel log is that it is
>> possible to overflow the kernel log with operations performed
>> exclusively in a container.
>> 
> I don't agree with you here.
>
> If we are double printing, we are using up more memory, but we also have
> an extra buffer anyway. The messages are print on behalf of the user,
> but still, by the kernel.
>
> So one of the following will necessarily hold:
>
> 1) There is no way that the process can overflow the main log, and as a
> consequence, the container log, that has less messages than it.
>
> 2) The process will overflow the main log. But since we are not printing
> anything extra to the main log compared to the scenario in which the
> process lives in the main namespace, this would already be a problem
> independent of namespaces. And needs to be fixed.

Well mounts, brining network interfaces up and down, running packets
through our own choice of firewall rules, possibly enabling debug
messages on network interfaces has the potential to create messages we
aren't seeing today.

> IOW, double printing should not print anything *extra* to the main log.
> It just prints to the container log, and leaves a copy to the box admin
> to see. I think it is very reasonable to imagine that the main admin
> would like to see anything the kernel has to tell him about the box.

The only reason that I have seen for doing anything with printks is
because we are generating messages that would not be generated in a
non-container environment.  At which point double printing is scary
because it allows a container user to flood the kernel log ring buffer
and suppress interesting messages.

>> I do think the idea of process context printks going to the current
>> container one worth playing with.
>> 
>
> It still leaves the problem of prinkts outside process context that
> should go to a namespace open. But it is easy to extend this idea to do
> both.

Hmm.  For printks from process context I think I can see a point where
double printing makes sense, because that is a rather indiscriminate grab
of printk messages.

Eric
