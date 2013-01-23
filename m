From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Wed, 23 Jan 2013 12:48:58 -0800
Message-ID: <CAGK4HS9qtB7uixResGpKuTXC5uUS-EZERhnfew-y7O5Ky791OQ@mail.gmail.com>
References: <20130122161038.GG4608@sociomantic.com>
	<1358873142.3464.3964.camel@edumazet-glaptop>
	<20130122165929.GH4608@sociomantic.com>
	<1358874800.3464.4002.camel@edumazet-glaptop>
	<50FED7CE.1030008@hp.com>
	<20130122184245.GJ4608@sociomantic.com>
	<50FF0C25.9000300@hp.com>
	<20130123104736.GK4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123104736.GK4608@sociomantic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 January 2013 02:47, Leandro Lucarella
<leandro.lucarella@sociomantic.com> wrote:
> On Tue, Jan 22, 2013 at 02:01:09PM -0800, Rick Jones wrote:
>> >>If that is being overflowed, I believe you should be seeing something like:
>> >>
>> >>     14 SYNs to LISTEN sockets dropped
>> >>
>> >>in the output of netstat -s on the system on which the server
>> >>application is running.
>> >
>> >What is that value reporting exactly?
>>
>> Netstat is reporting the ListenDrops and/or ListenOverflows  which
>> map to LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS.  Those
>> get incremented in tcp_v4_syn_recv_sock() (and its v6 version etc)
>>
>>        if (sk_acceptq_is_full(sk))
>>                 goto exit_overflow;
>>
>> Will increment both overflows and drops, and drops will increment on
>> its own in some additional cases.

Note that tcp_v4_conn_request() can also drop SYNs directly (start of
TWHS) if acceptq is full and more than one young requests are queued
up
vim +1504 tcp_ipv4.c

       if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
                goto drop;


These drops do not seem to be tracked by any MIB variable and so will
not show up in netstat
(Also, newer nstat is preferred to netstat ).
Maybe we need to track these drops too?

Vijay
