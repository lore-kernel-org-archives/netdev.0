From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Tue, 14 Aug 2012 12:46:37 +0400
Message-ID: <502A106D.6010306@parallels.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk> <20120810191149.GA17985@fieldses.org> <20120810202818.06236f46@pyramind.ukuu.org.uk> <50259494.8060304@zytor.com> <5025FA5A.4090403@parallels.com> <50263ECC.4060501@parallels.com> <20120813164730.GB2497@fieldses.org> <50293BE9.3010408@parallels.com> <20120813182431.GA4234@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org" <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120813182431.GA4234-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

13.08.2012 22:24, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, Aug 13, 2012 at 09:39:53PM +0400, Stanislav Kinsbursky wrote:
>> 13.08.2012 20:47, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Sat, Aug 11, 2012 at 03:15:24PM +0400, Stanislav Kinsbursky wrot=
e:
>>>> 11.08.2012 10:23, Pavel Emelyanov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> On 08/11/2012 03:09 AM, H. Peter Anvin wrote:
>>>>>> On 08/10/2012 12:28 PM, Alan Cox wrote:
>>>>>>> Explicitly for Linux yes - this is not generally true of the
>>>>>>> AF_UNIX socket domain and even the permissions aspect isn't
>>>>>>> guaranteed to be supported on some BSD environments !
>>>>>> Yes, but let's worry about what the Linux behavior should be.
>>>>>>
>>>>>>> The name is however just a proxy for the socket itself. You
>>>>>>> don't even get a device node in the usual sense or the same ino=
de
>>>>>>> in the file system space.
>>>>>> No, but it is looked up the same way any other inode is (the
>>>>>> difference between FIFOs and sockets is that sockets have separa=
te
>>>>>> connections, which is also why open() on sockets would be nice.)
>>>>>>
>>>>>> However, there is a fundamental difference between AF_UNIX socke=
ts
>>>>>> and open(), and that is how the pathname is delivered.  It thus
>>>>>> would make more sense to provide the openat()-like information i=
n
>>>>>> struct sockaddr_un, but that may be very hard to do in a sensibl=
e
>>>>>> way.  In that sense it perhaps would be cleaner to be able to do
>>>>>> an open[at]() on the socket node with O_PATH (perhaps there shou=
ld
>>>>>> be an O_SOCKET option, even?) and pass the resulting file
>>>>>> descriptor to bind() or connect().
>>>>> I vote for this (openat + O_WHATEVER on a unix socket) as well. I=
t
>>>>> will help us in checkpoint-restore, making handling of
>>>>> overmounted/unlinked sockets much cleaner.
>>>> I have to notice, that it's not enough and doesn't solve the issue=
=2E
>>>> There should be some way how to connect/bind already existent unix
>>>> socket (from kernel, at least), because socket can be created in u=
ser
>>>> space. And this way (sock operation or whatever) have to provide a=
n
>>>> ability to lookup UNIX socket starting from specified root to supp=
ort
>>>> containers.
>>> I don't understand--the rpcbind sockets are created by the kernel. =
 What
>>>  am I missing?
>>
>> Kernel preform connect to rpcbind socket (i.e. user-space binds it),
>> doesn't it?
>
> I'm confused, possibly because there are three "sockets" here: the
> client-side socket that's connected, the server-side socket that's bo=
und,
> and the common object that exists in the filesystem namespace.
>
> Userland creates the server-side socket and binds to it.  All of that=
 is
> done in the context of the rpcbind process, so is created in rpcbind'=
s
> namespace. That should be OK, right?
>
> The client side socket is created and connected in xs_local_setup_soc=
ket().
>
> Making sure they both end up with the same thing is a matter of makin=
g sure
> they lookup the same path in the same namespace.  The difficult part =
of that
> is the in-kernel client-side socket connect, where we don't have the =
right
> process context any more.
>

Looks like I'm missing something important.
Where are these UNIX in-kernel created and listening sockets (in code, =
I mean)?

--=20
Best regards,
Stanislav Kinsbursky
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
