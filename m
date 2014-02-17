From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: socket bind to local address ::ffff:127.0.0.1 question
Date: Mon, 17 Feb 2014 10:32:49 -0800
Message-ID: <CAK3+h2yQB32tJ-VDf9v9e6dw-AN8hJ3Nb3Z+7=2Gp+m6LFCzWQ@mail.gmail.com>
References: <CAK3+h2zzx5AocGeJxu9cW0kNkiRew6GNDMrbsNq-7H8co=T0_Q@mail.gmail.com>
	<20140215171041.GE8634@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Vincent Li <vincent.mc.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:59295 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbaBQSct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 13:32:49 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so17189768obc.6
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 10:32:49 -0800 (PST)
In-Reply-To: <20140215171041.GE8634@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry to respond late, I don't have code access to the program and no
sample code to reproduce the issue. the strace only shows connect and
getsockname trace. so the trouble shooting is very limited. the kernel
version is centos 6.2 based. (2.6.32*)

the strace file is too large to paste here, so I extract out the
relevant information I think related, the connect call finally returns
' EHOSTUNREACH (No route to host)'

6797  12:37:01.871842 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(46854), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151086333263900]) = 0

6797  12:37:01.872186 close(11)         = 0 <---here closed descriptor 11

------another new connection opened for discriptor 11, this is
successfull one monitor instance----

6797  12:37:02.871031 fcntl64(11, F_SETFL, O_RDONLY|O_NONBLOCK) = 0

6797  12:37:02.871121 fcntl64(11, F_SETFD, FD_CLOEXEC) = 0

6797  12:37:02.871229 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.166",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
EINPROGRESS (Operation now in progress)

6797  12:37:02.873006 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433145657494601756]) = 0

6797  12:37:02.876424 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151292491694108]) = 0

6797  12:37:02.878081 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151155052740636]) = 0

6797  12:37:02.878353 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.166",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = 0

6797  12:37:02.878467 getsockopt(11, SOL_TCP, TCP_MAXSEG,
[700869393474651560], [4]) = 0

6797  12:37:02.878553 fcntl64(11, F_GETFL) = 0x802 (flags O_RDWR|O_NONBLOCK)

6797  12:37:02.878673 fcntl64(11, F_SETFL, O_RDWR|O_NONBLOCK) = 0

6797  12:37:02.878768 fcntl64(11, F_SETFD, FD_CLOEXEC) = 0

6797  12:37:02.878851 setsockopt(11, SOL_TCP, TCP_NODELAY, [1], 4) = 0

6797  12:37:02.880352 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151155052740636]) = 0

6797  12:37:02.880884 write(11, "GET /status HTTP/1.0\r\n\r\n", 24) =
24 <---monitor http request

6797  12:37:02.882551 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151155052740636]) = 0

6797  12:37:02.886150 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151292491694108]) = 0

6797  12:37:02.887843 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151086333263900]) = 0

6797  12:37:02.888096 read(11, "HTTP/1.1 200 OK\r\nServer:
Apache-"..., 5120) = 3175 <----server response ok

6797  12:37:02.888214 read(11, "", 1945) = 0

6797  12:37:02.889833 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151086333263900]) = 0

6797  12:37:02.891532 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(33334), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151086333263900]) = 0

6797  12:37:02.891896 close(11)         = 0 <-------this sucessfull
monitor instance closed

------a failed monitor instance started on discriptor 11, no
getsockopt and setsockopt traced-----------

6797  12:37:03.790155 fcntl64(11, F_SETFL, O_RDONLY|O_NONBLOCK) = 0

6797  12:37:03.790237 fcntl64(11, F_SETFD, FD_CLOEXEC) = 0

6797  12:37:03.790342 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
EINPROGRESS (Operation now in progress)

6797  12:37:03.791998 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(45633), inet_pton(AF_INET6, "::ffff:127.0.0.1",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433145657494601756]) = 0

6797  12:37:06.796980 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(45633), inet_pton(AF_INET6, "::ffff:127.0.0.1",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151292491694108]) = 0

6797  12:37:06.798645 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(45633), inet_pton(AF_INET6, "::ffff:127.0.0.1",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433151155052740636]) = 0

6797  12:37:06.798919 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
EHOSTUNREACH (No route to host)


6797  12:37:06.800437 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(45633), inet_pton(AF_INET6, "::", &sin6_addr),
sin6_flowinfo=0, sin6_scope_id=0}, [18433150467857973276]) = 0

6797  12:37:06.800777 close(11)         = 0

we have continuously ip route dump when the issue happend 'ip route
get 172.16.3.165', there is always default route to 172.16.3.165 and
the we also see the SYN packet going out on the wire sourcing from
127.0.0.1, so there is no layer 2 arp issue and no icmp error packet
reported that is why I am looking for if there is potential kernel
issue here.












On Sat, Feb 15, 2014 at 9:10 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Feb 12, 2014 at 12:41:21PM -0800, Vincent Li wrote:
>> we have a traffic path like <BIGIP monitor userland process on Linux>
>> <------> router<------->pool/real server
>>
>> there is a  weird issue that intermittently, a socket is bound to
>> loopback address '::ffff:127.0.0.1' which caused issue for us because
>> remote end host can't SYN+ACK the SYN source from 127.0.0.1, strace
>> the userland process shows:
>>
>> 6797  12:36:48.815296 connect(11, {sa_family=AF_INET6,
>> sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
>> &sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
>> EINPROGRESS (Operation now in progress)
>
> Have you checked the connect operation completed successfully in this
> case? Error state would be interesting to see (SO_ERROR).
>
>> 6797  12:36:48.815464 gettimeofday({1391744208, 815499}, NULL) = 0
>> 6797  12:36:48.815552 time(NULL)        = 1391744208
>> 6797  12:36:48.815657 stat64("/etc/localtime", {st_mode=S_IFREG|0644,
>> st_size=331, ...}) = 0
>> ...................
>> 6797  12:36:48.816948 getsockname(11, {sa_family=AF_INET6,
>> sin6_port=htons(45621), inet_pton(AF_INET6, "::ffff:127.0.0.1",
>> &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
>> [18433145657494601756]) = 0
>    ^^^
> Urks!
>
> What kernel version are you using?
>
> Do you have a reproducer, sample code in C where this problem sometimes
> happens or could you expand the strace listings a bit (maybe setsockopts,
> bindv6only settings)?
>
> Also you seem to not initialize your struct sockaddr_in6 given to connect, as
> the sin6_scope_id seems bogus (uninitialized memory?). But should not
> matter with v4mapped addresses though.
>
> Greetings,
>
>   Hannes
>
>
