From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: sctp_diag should dump sctp socket type
Date: Sat, 28 May 2016 00:06:27 +0800
Message-ID: <CADvbK_cucfLqF1_2MEeQN9Ljwx79jbW-0bFVeNWx2xBYU2j1PQ@mail.gmail.com>
References: <53ebf63eb6de080418949f52d0d3556af2a371e1.1464203668.git.lucien.xin@gmail.com>
	<1464207719.5939.73.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem <davem@davemloft.net>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	Phil Sutter <phil@nwl.cc>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34849 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755824AbcE0QGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:06:33 -0400
In-Reply-To: <1464207719.5939.73.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 4:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-05-26 at 03:14 +0800, Xin Long wrote:
>> Now we cannot distinguish that one sk is a udp or sctp style when
>> we use ss to dump sctp_info. it's necessary to dump it as well.
>>
>> For sctp_diag, ss support is not officially available, thus there
>> are no official users of this yet, so we can add this field in the
>> middle of sctp_info without breaking user API.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  include/linux/sctp.h | 1 +
>>  net/sctp/socket.c    | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
>> index dacb5e7..3a406af 100644
>> --- a/include/linux/sctp.h
>> +++ b/include/linux/sctp.h
>> @@ -761,6 +761,7 @@ struct sctp_info {
>>       __u32   sctpi_s_autoclose;
>>       __u32   sctpi_s_adaptation_ind;
>>       __u32   sctpi_s_pd_point;
>> +     __u32   sctpi_s_type;
>
> Well, this is also adding a 4-byte padding at the end of the structure.
>
>
> Basically, because of the 8-byte alignment cause by the __u64 fields,
> adding a single __u32 adds a padding.
>
> Don't you have another u32 info you'd like to publish ?
>
these days, I was trying to find an right u32 one for here, but no good
one, so I will put a __u32   __reserved3; there.

sctp still have some feature haven't yet been implemented, maybe
after that, we will find a good one. :)


>
>
