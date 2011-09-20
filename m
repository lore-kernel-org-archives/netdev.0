From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Tue, 20 Sep 2011 08:14:24 +0200
Message-ID: <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
References: <20110919121940.GA19942@synalogic.ca> <20110919130313.GA27819@hmsreliant.think-freely.org>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110919130313.GA27819-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Benjamin, Neil,

On Mon, Sep 19, 2011 at 3:03 PM, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wr=
ote:
> On Mon, Sep 19, 2011 at 08:19:40AM -0400, Benjamin Poirier wrote:
>> Hi,
>>
>> I noticed what appears to be a discrepancy between the ip(7) man pag=
e
>> and the kernel code with regards to the IP DF flag for UDP sockets.
>>
>> The man page says that "The don't-fragment flag is set on all outgoi=
ng
>> datagrams" and that the ip_no_pmtu_disc sysctl affects only SOCK_STR=
EAM
>> sockets. This is quickly disproved by doing:
>> echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
>> firing up netcat and looking at a few outgoing udp packets in wiresh=
ark
>> (they don't have the DF flag set).

Could you describe the required change in terms of how the man page
text should look--i.e., rewrite the passage as you think it should
look?

Thanks,

Michael


>> 1) in the words of `man 7 ip`:
>> IP_MTU_DISCOVER (since Linux 2.2)
>> =A0 =A0 =A0 Set or receive the Path MTU Discovery =A0setting =A0for =
=A0a =A0socket.
>> =A0 =A0 =A0 When =A0enabled, Linux will perform Path MTU Discovery a=
s defined
>> =A0 =A0 =A0 in RFC 1191 on this socket. =A0The don't-fragment flag i=
s set =A0on
>> =A0 =A0 =A0 all =A0outgoing datagrams. =A0The system-wide default is=
 controlled
>> =A0 =A0 =A0 by the /proc/sys/net/ipv4/ip_no_pmtu_disc file for =A0SO=
CK_STREAM
>> =A0 =A0 =A0 sockets, and disabled on all others.
>>
>> This is the text present in the latest version of the online manpage=
s,
>> http://webcache.googleusercontent.com/search?q=3Dcache:http://www.ke=
rnel.org/doc/man-pages/reporting_bugs.html&ie=3DUTF-8
>>
>> 2) in net/ipv4/af_inet.c:inet_create():
>> =A0 =A0 =A0 if (ipv4_config.no_pmtu_disc)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet->pmtudisc =3D IP_PMTUDISC_DONT;
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet->pmtudisc =3D IP_PMTUDISC_WANT;
>>
>> and pmtudisc is left alone from there on for UDP sockets.
>>
>> What should be adjusted, the man page or the code?
>>
> The man page is wrong I think
>
> By my read, the code:
> 1) Affects UDP and TCP the same way (which makes sense to me)
>
> 2) Is doing exactly what you asked it to, since you set no_pmtu_disc,=
 which
> means the stack should be free to fragment a frame as it sees fit acc=
ording to
> the MTU metric of the route its traversing, hence the cleared DF bit =
in the
> fraem.
>
> RFC 1191 can apply equally well to udp, as tcp, and is evident in tha=
t you can
> set the per-socket option IP_MTU_DISCOVER to any of the 4 acceptible =
values
> offered (DONT/WANT/DO/PROBE), so theres no reason the sysctl governin=
g the
> default value at creation shouldn't apply as well.
> Neil
>
>



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
