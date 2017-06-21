From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH v2] net/sctp/ulpevent.c: Deinline sctp_ulpevent_set_owner,
 save 1616 bytes
Date: Wed, 21 Jun 2017 21:45:04 +0200
Message-ID: <8d25a6ac-8733-8ab6-7edf-601d45402d53@redhat.com>
References: <20170621170327.4873-1-dvlasenk@redhat.com>
 <20170621192442.GH18138@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621192442.GH18138@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2017 09:24 PM, Marcelo Ricardo Leitner wrote:
> On Wed, Jun 21, 2017 at 07:03:27PM +0200, Denys Vlasenko wrote:
>> This function compiles to 147 bytes of machine code. 13 callsites.
>>
>> I'm no expert on SCTP events, but quick reading of SCTP docs tells me that
>> SCTP events are not happening on every packet.
>> They are ASSOC_CHANGE, PEER_ADDR_CHANGE, REMOTE_ERROR and such.
>> Does not look performance critical.
>>
>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>> CC: Vlad Yasevich <vyasevich@gmail.com>
>> CC: Neil Horman <nhorman@tuxdriver.com>
>> CC: David Miller <davem@davemloft.net>
>> CC: linux-sctp@vger.kernel.org
>> CC: netdev@vger.kernel.org
>> CC: linux-kernel@vger.kernel.org
>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>
> Just wondering, are you conducting further research on this topic?
> Because we probably could use such review on SCTP stack.

Here is the list of sctp inlines which has any (however small)
benefit when deinlined.

filename:lineno:inline_name:lines_of_source_code:saved_bytes_by_deinlining:size_of_code_of_deinlined_function

include/net/sctp/command.h:228:sctp_add_cmd_sf:7:8306:38
net/sctp/ulpevent.c:91:sctp_ulpevent_set_owner:13:1616:147
include/net/sctp/sctp.h:414:sctp_skb_set_owner_r:10:934:75
net/sctp/input.c:840:sctp_hash_key:13:896:359
net/sctp/input.c:823:sctp_hash_obj:13:704:409
include/net/sctp/checksum.h:60:sctp_compute_cksum:13:595:85
net/sctp/input.c:800:sctp_hash_cmp:18:320:124
net/sctp/socket.c:117:sctp_wspace:19:256:76
include/net/sctp/sctp.h:272:sctp_max_rto:7:204:68
net/sctp/socket.c:173:sctp_verify_addr:15:192:72
include/net/sctp/checksum.h:46:sctp_csum_update:4:147:21
include/net/sctp/sctp.h:519:param_type2af:8:134:35
include/net/sctp/sctp.h:399:sctp_list_dequeue:7:123:59
include/net/sctp/sctp.h:596:sctp_transport_dst_check:4:120:60
include/net/sctp/sctp.h:435:sctp_frag_point:12:65:65
net/sctp/outqueue.c:82:sctp_outq_dequeue_data:10:64:87
include/net/sctp/command.h:243:sctp_next_cmd:4:64:37
include/net/sctp/sm.h:347:sctp_data_size:6:19:19

For .c files, the patches are trivial and I have them auto-generated,
I'll send them to you privately to save you the mechanical work.

Unfortunately, for inlines in .h files this does not work
(a human is needed to decide where to more the function).

Of course, not every deinlining makes sense.
