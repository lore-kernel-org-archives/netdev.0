From: Matthew Helsley <matt.helsley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Sat, 27 Aug 2011 16:39:11 -0700
Message-ID: <CA+RrjuXe8kcU+rWT5v88x3u_CMwsdnEAFj7mjDU22p57HCeHhA@mail.gmail.com>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org>
	<4E55A55B.8090608@parallels.com>
	<20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
	<m14o16qlq1.fsf@fess.ebiederm.org> <4E56464B.4070304@monom.org>
	<4E5664B5.6000806@genband.com> <4E56942A.3080905@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
        Chris Friesen <chris.friesen-b7o/lNNmKxtBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E56942A.3080905-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2011 at 11:27 AM, Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org> wrote:

> Hi Chris,
>
> On 08/25/2011 05:05 PM, Chris Friesen wrote:
> > On 08/25/2011 06:55 AM, Daniel Wagner wrote:
> >
> >> I'd like to solve a use case where it is necessary to count all bytes
> >> transmitted and received by an application [1]. So far I have found two
> >> unsatisfying solution for it. The first one is to hook into libc and
> >> count the bytes there. I don't think I have to say I don't like this.
> >
> > Is there any particular reason you can't use LD_PRELOAD to interpose a
> > library to do the statistics monitoring?
>
> This is certainly possible to do for any dynamic linked application. I
> think it wouldn't work for static linked ones. Currently I don't know if
> I have to face such application on the project I am on. The reason why I
> am not so a big fan is that using the LD_PRELOAD trick seems very
> hackish to me.
>

LD_PRELOAD is widely regarded as a debugging and tracing method -- it's not
usually suitable for implementing features. Why? Because there's nothing
stopping an application from resetting LD_PRELOAD and re-exec'ing to escape
the measurements and limitations such a preload implements. Plus naive use
of LD_PRELOAD could easily interfere with other things that use it. For
example what if you want to use DMTCP with this?

Cheers,
    -Matt
