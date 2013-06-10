From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when
 performing the upcall
Date: Mon, 10 Jun 2013 13:34:23 -0700
Message-ID: <CAEP_g=87=0bAP_QQVVXRXzqMA-9Xj5dXvsjpfe4MQ_k2x5n9cA@mail.gmail.com>
References: <cover.1369406826.git.tgraf@suug.ch> <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
 <1369421900.3301.431.camel@edumazet-glaptop> <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
 <1369432621.3301.445.camel@edumazet-glaptop> <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
 <20130525070222.GB30252@casper.infradead.org> <1369492772.3301.468.camel@edumazet-glaptop>
 <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com> <20130607122139.GA21856@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:35566 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752090Ab3FJUeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:34:44 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so4014864ied.28
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:34:43 -0700 (PDT)
In-Reply-To: <20130607122139.GA21856@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 7, 2013 at 5:21 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 05/27/13 at 10:28am, Jesse Gross wrote:
>> On Saturday, May 25, 2013, Eric Dumazet wrote:
>>
>> > On Sat, 2013-05-25 at 08:02 +0100, Thomas Graf wrote:
>> >
>> > > I ran TCP_CRR to verify the SYN/ACK use case and I did not
>> > > observe a difference. If you have any specific test in mind
>> > > I will be glad to run that before posting the 2nd revision.
>> >
>> > I guess you should test with rx checksum disabled as well, Jesse seemed
>> > to be concerned about that.
>>
>>
>>  I was actually thinking about the transmit side - rx checksum verification
>> doesn't matter much here since the result will get thrown away. However, if
>> the packet is CHECKSUM_PARTIAL then the checksum will have to get filled in
>> first and that's the code path that is a little different now.
>
> Do we actually need to complete the checksum before doing the
> upcall and if so, why? Couldn't the slow path do that if needed?
> The only reason I can think of where it would matter is if a
> controller injects the packet into another network stack such
> as RouteFlow.

Well, this is the slow path. I don't want to force userspace to deal
with this because it's an internal kernel optimization that is
platform-specific and requires carrying additional metadata around.

It's also very common for a packet to traverse another network stack -
it's typically a VM's.
