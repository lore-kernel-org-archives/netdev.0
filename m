From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] socket.7: Document SO_INCOMING_CPU
Date: Wed, 19 Apr 2017 13:13:21 -0700
Message-ID: <1492632801.22296.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABNn7+rHfUTjMtm3Biqfx83G6Rr7pY-LuHXY=JqA6N3H_SstZg@mail.gmail.com>
         <63815aac-9c8f-c599-9422-5c312cefc9e8@gmail.com>
         <9c754f31-8ace-03f2-97f3-81e29eb6d997@gmail.com>
         <1492621535.22296.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <326b99c3-cc86-3abd-1069-2b3a52d9ba47@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Saint-Jacques <fsaintjacques-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <326b99c3-cc86-3abd-1069-2b3a52d9ba47-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-19 at 20:48 +0200, Michael Kerrisk (man-pages) wrote:
> Hi Eric,
> 
> [reodering for clarity]
> 
> >> On 02/19/2017 09:55 PM, Michael Kerrisk (man-pages) wrote:
> >>> [CC += Eric, so that he might review]
> >>>
> >>> Hello Francois,
> >>>
> >>> On 02/18/2017 05:06 AM, Francois Saint-Jacques wrote:
> >>>> This socket option is undocumented. Applies on the latest version
> >>>> (man-pages-4.09-511).
> >>>>
> >>>> diff --git a/man7/socket.7 b/man7/socket.7
> >>>> index 3efd7a5d8..1a3ffa253 100644
> >>>> --- a/man7/socket.7
> >>>> +++ b/man7/socket.7
> >>>> @@ -490,6 +490,26 @@ flag on a socket
> >>>>  operation.
> >>>>  Expects an integer boolean flag.
> >>>>  .TP
> >>>> +.BR SO_INCOMING_CPU " (getsockopt since Linux 3.19, setsockopt since
> >>>> Linux 4.4)"
> >>>> +.\" getsocktop 2c8c56e15df3d4c2af3d656e44feb18789f75837
> >>>> +.\" setsocktop 70da268b569d32a9fddeea85dc18043de9d89f89
> >>>> +Sets or gets the cpu affinity of a socket. Expects an integer flag.
> >>>> +.sp
> >>>> +.in +4n
> >>>> +.nf
> >>>> +int cpu = 1;
> >>>> +socklen_t len = sizeof(cpu);
> >>>> +setsockopt(fd, SOL_SOCKET, SO_INCOMING_CPU, &cpu, &len);
> >>>> +.fi
> >>>> +.in
> >>>> +.sp
> >>>> +The typical use case is one listener per RX queue, as the associated listener
> >>>> +should only accept flows handled in softirq by the same cpu.  This provides
> >>>> +optimal NUMA behavior and keep cpu caches hot.
> >>>> +.TP
> >>>>  .B SO_KEEPALIVE
> >>>>  Enable sending of keep-alive messages on connection-oriented sockets.
> >>>>  Expects an integer boolean flag.
> >>>
> >>> Thank you! Patch applied.
> >>>
> >>> I have tried to enhance the description somewhat. I'm not sure whether
> >>> what I've written is quite correct (or whether it should be further
> >>> extended). Eric, could you please take a look at the following, and let 
> >>> me know if anything needs fixing:
> >>>
> >>>        SO_INCOMING_CPU  (gettable  since Linux 3.19, settable since Linux
> >>>        4.4)
> >>>               Sets or gets the CPU affinity  of  a  socket.   Expects  an
> >>>               integer flag.
> >>>
> >>>                   int cpu = 1;
> >>>                   socklen_t len = sizeof(cpu);
> >>>                   setsockopt(fd, SOL_SOCKET, SO_INCOMING_CPU, &cpu, &len);
> >>>
> >>>               Because  all  of the packets for a single stream (i.e., all
> >>>               packets for the same 4-tuple) arrive on the single RX queue
> >>>               that  is  associated with a particular CPU, the typical use
> >>>               case is to employ one listening process per RX queue,  with
> >>>               the  incoming  flow being handled by a listener on the same
> >>>               CPU that is handling the RX queue.  This  provides  optimal
> >>>               NUMA behavior and keeps CPU caches hot.
> 
> > Hi Michael
> > 
> > Sorry for the delay.
> 
> Thanks for the reply, but I think you are assuming I know more than 
> I do. I'd like you to elaborate a little please. See below.
> 
> > Note that setting the option is not supported if SO_REUSEPORT is used.
> 
> Please define "not supported". Does this yield an API diagnostic?
> If so, what is it?
> 
> > Socket will be selected from an array, either by a hash or BPF program
> > that has no access to this information.
> 
> Sorry -- I'm lost here. How does this comment relate to the proposed
> man page text above?

Simply that :

If an application uses both SO_INCOMING_CPU and SO_REUSEPORT, then
SO_REUSEPORT logic, selecting the socket to receive the packet, ignores
SO_INCOMING_CPU setting.

This does not need to be documented, because it is an implementation
detail/bug that could be changed, if someone cares enough.



--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
