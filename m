From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: sctp_seq_dump_local_addrs: fix NULL pointer
 dereference
Date: Wed, 12 Jun 2013 15:04:14 +0200
Message-ID: <51B871CE.3090602@redhat.com>
References: <1370969266-16974-1-git-send-email-dborkman@redhat.com> <20130612125600.GF13059@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362Ab3FLNE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 09:04:28 -0400
In-Reply-To: <20130612125600.GF13059@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 02:56 PM, Neil Horman wrote:
> On Tue, Jun 11, 2013 at 06:47:46PM +0200, Daniel Borkmann wrote:
>> The following NULL pointer dereference has occured on a 2.6.32-358 k=
ernel,
>> but upstream is affected as well since there are not many difference=
s:
>>
>> sctp protocol violation state 4 chunkid 8
>> BUG: unable to handle kernel NULL pointer dereference at 00000000000=
00078
>> IP: [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
>> PGD c2758c067 PUD 87ecf1067 PMD 0
>> Oops: 0000 [#1] SMP
>> last sysfs file: /sys/devices/pci0000:00/0000:00:0a.0/0000:02:00.1/l=
ocal_cpus
>> CPU 7
>> Modules linked in: [...]
>> Pid: 15475, comm: netstat Not tainted 2.6.32-358.el6.x86_64 #1 KONTR=
ON AT8050/FYA/AT8050/FYA
>> RIP: 0010:[<ffffffffa0354cac>]  [<ffffffffa0354cac>] sctp_v4_cmp_add=
r+0xc/0x30 [sctp]
>> RSP: 0018:ffff880c280f3d08  EFLAGS: 00010206
>> RAX: 0000000000000002 RBX: ffff880827a25c00 RCX: 0000000000000001
>> RDX: 000000000000027f RSI: 0000000000000078 RDI: ffff880827a25c20
>> RBP: ffff880c280f3d08 R08: 00000000fffffffd R09: 0000000000000001
>> R10: 0000000000000003 R11: 0000000000000000 R12: ffff880c27d9d870
>> R13: ffffffffa03751c0 R14: ffff880827a25c20 R15: 0000000000000078
>> FS:  00007fb7b7d0f7a0(0000) GS:ffff8800282e0000(0000) knlGS:00000000=
00000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>   -- MORE --  forward: <SPACE>, <ENTER> or j  backward: b or k  quit=
: q
>> CR2: 0000000000000078 CR3: 000000087c36d000 CR4: 00000000000007e0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process netstat (pid: 15475, threadinfo ffff880c280f2000, task ffff8=
8091e361540)
>> Stack:
>>   ffff880c280f3d58 ffffffffa036dbac ffff880c280f3d28 ffff88098fefebc=
0
>> <d> ffff880c280f3d38 ffff880c27d9d800 ffff88098fefebc0 0000000000000=
f83
>> <d> ffff8808d12a7b80 ffff880c27d9d948 ffff880c280f3e18 ffffffffa036d=
e3d
>> Call Trace:
>>   [<ffffffffa036dbac>] sctp_seq_dump_local_addrs+0x6c/0xc0 [sctp]
>>   [<ffffffffa036de3d>] sctp_assocs_seq_show+0x12d/0x250 [sctp]
>>   [<ffffffff811a4ee0>] ? seq_read+0x0/0x400
>>   [<ffffffff811a5169>] seq_read+0x289/0x400
>>   [<ffffffff811e966e>] proc_reg_read+0x7e/0xc0
>>   [<ffffffff811816c5>] vfs_read+0xb5/0x1a0
>>   [<ffffffff81181801>] sys_read+0x51/0x90
>>   [<ffffffff810dc565>] ? __audit_syscall_exit+0x265/0x290
>>   [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
>> Code: 02 00 08 8b 47 04 89 46 04 b8 08 00 00 00 c9 c3 66 66 66 66 66=
 66
>>        2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 44 00 00 0f b7 0=
7 <66>
>>        3b 06 74 07 31 c0 c9 c3 0f 1f 00 0f b7 47 02 66 3b 46 02 75
>> RIP  [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
>>   RSP <ffff880c280f3d08>
>> CR2: 0000000000000078
>>
>> ./decodecode < oops.file:
>>    ...
>>    1f:	55                   	push   %rbp
>>    20:	48 89 e5             	mov    %rsp,%rbp
>>    23:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
>>    28:	0f b7 07             	movzwl (%rdi),%eax
>>    2b:*	66 3b 06             	cmp    (%rsi),%ax  <-- trapping instru=
ction
>>    2e:	74 07                	je     0x37       (1st 'if' in sctp_v4_=
cmp_addr)
>>    30:	31 c0                	xor    %eax,%eax
>>    32:	c9                   	leaveq
>>    33:	c3                   	retq
>>    34:	0f 1f 00             	nopl   (%rax)
>>    37:	0f b7 47 02          	movzwl 0x2(%rdi),%eax
>>    ...
>>
>> There have been some approaches to fix corruptions with the same or
>> very similar stack trace such as 2eebc1e ("sctp: Fix list corruption
>> resulting from freeing an association on a list"), 0b0fe913 ("sctp:
>> proc: protect bind_addr->address_list accesses with rcu_read_lock()"=
),
>> 45122ca ("sctp: Add RCU protection to assoc->transport_addr_list")
>> that are all important fixes, but the panic still can occur in some
>> cases with such a stack trace above.
>>
>> When entering into sctp_seq_dump_local_addrs(), the sctp_ep_common
>> structure is correctly of type SCTP_EP_TYPE_ASSOCIATION, and has a
>> refcnt of 1 and dead is 0. Also from kdump, the ebp's pointer member=
s
>> do not look corrupted. When entering sctp_v4_cmp_addr(), the first
>> sctp_addr argument looks good/valid, but the second sctp_addr argume=
nt
>> ('primary') is 0000000000000078 and results suddenly in a NULL point=
er
>> _dereference_ in sctp_v4_cmp_addr() although in the test before it
>> seems to have been "primary !=3D NULL".
>>
>> Now, how can this happen? Let's assume asoc->peer.primary_path is NU=
LL
>> which is possible to happen. Here, we do not check for it, but take =
the
>> address (note we do not actually dereference it!) of its saddr membe=
r.
>> This is then exactly 0000000000000078 as reported in the trace, sinc=
e
>> that is equal to the offset of saddr from the primary_path container
>> (in the reported kernel). Thus, the check for NULL (=3D=3D (void *) =
0) will
>> pass, eventually leading to the NULL pointer dereference in cmp_addr=
()
>> since this address is within the NULL page.
>>
>> Lets fix it by being paranoid and checking first if our primary tran=
sport
>> is !=3D NULL and in case of !=3D NULL if it is alive. Then, let us h=
old a
>> copy of the sctp_addr on the stack instead of using a pointer just i=
n
>> case the transport could be destroyed at a later point in time (we'r=
e not
>> in a hurry anyway). By that, we can avoid this very scenario, only j=
ust
>> for the sake of printing this asterisk and can fix the NULL pointer
>> dereference eventually. Introduced by bca735bd ("Extend the info exp=
orted
>> via /proc/net/sctp to support netstat for SCTP.").
>>
> First off, nice analysis Daniel, that very clear and consice.  The pa=
tch below
> makes sense to me, but I'm getting the impression that, if we need to=
 use the
> dead flag here, that rcu_locking isn't going to be safe. If we aren't=
 guaranteed
> that saddr is going to be a valid pointer or NULL, and as a consequen=
ce are
> going to need to rely on the ->dead flag, then we have a potential ra=
ce
> condition to worry about.  I think the transport pointer is safe here=
, as its
> rcu protected in the free path, but its parent association is not.  B=
y getting
> the assocation that a given trasport points to, we risk a race with t=
he
> destruction of that association (I think).  We probably need to conve=
rt the
> association create/free paths (as well as the endpoint, etc, create/f=
ree paths),
> to be rcu sensitive, but for the time being, it may be sufficient to =
simply hold
> the association in sctp_seq_dump_local_addrs.

Well, checking for ->dead might be unnecessary and can probably be dele=
ted (if wished
I can do that and resubmit).

At the time of the crash, the association was in SCTP_STATE_CLOSED and =
the pointer to
primary_path in fact NULL.

The association looks as follows:

crash> sctp_association ffff880c27d9d800 |grep primary_path
     primary_path =3D 0x0,

The full structure is as follows:

crash> sctp_association ffff880c27d9d800
struct sctp_association {
   base =3D {
     node =3D {
       next =3D 0xffff880c25bd2000,
       pprev =3D 0xffff880c2ba0f838
     },
     hashent =3D 3971,
     type =3D SCTP_EP_TYPE_ASSOCIATION,
     refcnt =3D {
       counter =3D 1
     },
     dead =3D 0 '\000',
     malloced =3D 1 '\001',
     sk =3D 0xffff8808d12a7b80,
     inqueue =3D {
       in_chunk_list =3D {
         next =3D 0xffff880c27d9d828,
         prev =3D 0xffff880c27d9d828
       },
       in_progress =3D 0x0,
       immediate =3D {
         data =3D {
           counter =3D 0
         },
         entry =3D {
           next =3D 0xffff880c27d9d848,
           prev =3D 0xffff880c27d9d848
         },
         func =3D 0xffffffffa0358120 <sctp_assoc_bh_rcv>
       },
       malloced =3D 0
     },
     bind_addr =3D {
       port =3D 3868,
       address_list =3D {
         next =3D 0xffff880827a25c00,
         prev =3D 0xffff880827a25c80
       },
       malloced =3D 0
     }
   },
   asocs =3D {
     next =3D 0xffff880c1bf17888,
     prev =3D 0xffff880c25bd2088
   },
   assoc_id =3D 0,
   ep =3D 0xffff8808c0ab1800,
   c =3D {
     my_vtag =3D 1991531349,
     peer_vtag =3D 2306202495,
     my_ttag =3D 0,
     peer_ttag =3D 0,
     expiration =3D {
       tv_sec =3D 1368105862,
       tv_usec =3D 623303
     },
     sinit_num_ostreams =3D 4,
     sinit_max_instreams =3D 4,
     initial_tsn =3D 1248969237,
     peer_addr =3D {
       v4 =3D {
         sin_family =3D 2,
         sin_port =3D 36883,
         sin_addr =3D {
           s_addr =3D 3875562594
         },
         __pad =3D "\000\000\000\000\000\000\000"
       },
       v6 =3D {
         sin6_family =3D 2,
         sin6_port =3D 36883,
         sin6_flowinfo =3D 3875562594,
         sin6_addr =3D {
           in6_u =3D {
             u6_addr8 =3D "\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000",
             u6_addr16 =3D {0, 0, 0, 0, 0, 0, 0, 0},
             u6_addr32 =3D {0, 0, 0, 0}
           }
         },
         sin6_scope_id =3D 0
       },
       sa =3D {
         sa_family =3D 2,
         sa_data =3D "\023\220bd\000\347\000\000\000\000\000\000\000"
       }
     },
     my_port =3D 3868,
     prsctp_capable =3D 1 '\001',
     padding =3D 0 '\000',
     adaptation_ind =3D 2306202495,
     auth_random =3D "\200\002\000$L\347\r\360%\302\003O\337v\303W\342\=
326\341\033=CC=93\331\064\r=E4=8E=B4\254\374\364\343\253\037\360", <inc=
omplete sequence \320>,
     auth_hmacs =3D "\000\000\000\000\000\000\000\000\000",
     auth_chunks =3D "\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000",
     raw_addr_list_len =3D 16,
     peer_init =3D 0xffff880c27d9d93c
   },
   peer =3D {
     rwnd =3D 65535,
     transport_addr_list =3D {
       next =3D 0xffff880c27d9d948,
       prev =3D 0xffff880c27d9d948
     },
     transport_count =3D 0,
     port =3D 5008,
     primary_path =3D 0x0,
     primary_addr =3D {
       v4 =3D {
         sin_family =3D 0,
         sin_port =3D 0,
         sin_addr =3D {
           s_addr =3D 0
         },
         __pad =3D "\000\000\000\000\000\000\000"
       },
       v6 =3D {
         sin6_family =3D 0,
         sin6_port =3D 0,
         sin6_flowinfo =3D 0,
         sin6_addr =3D {
           in6_u =3D {
             u6_addr8 =3D "\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000",
             u6_addr16 =3D {0, 0, 0, 0, 0, 0, 0, 0},
             u6_addr32 =3D {0, 0, 0, 0}
           }
         },
         sin6_scope_id =3D 0
       },
       sa =3D {
         sa_family =3D 0,
         sa_data =3D "\000\000\000\000\000\000\000\000\000\000\000\000\=
000"
       }
     },
     active_path =3D 0x0,
     retran_path =3D 0x0,
     last_sent_to =3D 0x0,
     last_data_from =3D 0x0,
     tsn_map =3D {
       tsn_map =3D 0x0,
       base_tsn =3D 0,
       cumulative_tsn_ack_point =3D 0,
       max_tsn_seen =3D 0,
       len =3D 0,
       pending_data =3D 0,
       num_dup_tsns =3D 0,
       dup_tsns =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
     },
     sack_needed =3D 1 '\001',
     sack_cnt =3D 0,
     sack_generation =3D 1,
     ecn_capable =3D 0 '\000',
     ipv4_address =3D 1 '\001',
     ipv6_address =3D 0 '\000',
     hostname_address =3D 0 '\000',
     asconf_capable =3D 0 '\000',
     prsctp_capable =3D 1 '\001',
     auth_capable =3D 0 '\000',
     adaptation_ind =3D 2306202495,
     addip_disabled_mask =3D 0,
     i =3D {
       init_tag =3D 0,
       a_rwnd =3D 0,
       num_outbound_streams =3D 0,
       num_inbound_streams =3D 0,
       initial_tsn =3D 0
     },
     cookie_len =3D 0,
     cookie =3D 0x0,
     addip_serial =3D 0,
     peer_random =3D 0x0,
     peer_chunks =3D 0x0,
     peer_hmacs =3D 0x0
   },
   state =3D SCTP_STATE_CLOSED,
   cookie_life =3D {
     tv_sec =3D 60,
     tv_usec =3D 0
   },
   overall_error_count =3D 0,
   rto_initial =3D 2000,
   rto_max =3D 2000,
   rto_min =3D 500,
   max_burst =3D 4,
   max_retrans =3D 6,
   pf_retrans =3D 2147483647,
   max_init_attempts =3D 26352,
   init_retries =3D 0,
   max_init_timeo =3D 5049,
   hbinterval =3D 30000,
   pathmaxrxt =3D 3,
   pmtu_pending =3D 0 '\000',
   pathmtu =3D 0,
   param_flags =3D 41,
   sackdelay =3D 200,
   sackfreq =3D 2,
   timeouts =3D {0, 2000, 2000, 2000, 0, 0, 10000, 0, 200, 0},
   timers =3D {{
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa0354960 <sctp_generate_t1_cookie_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa0354940 <sctp_generate_t1_init_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa0354920 <sctp_generate_t2_shutdown_event=
>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa0354900 <sctp_generate_t4_rto_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa03548e0 <sctp_generate_t5_shutdown_guard=
_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa03548c0 <sctp_generate_sack_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }, {
       entry =3D {
         next =3D 0x0,
         prev =3D 0x0
       },
       expires =3D 0,
       function =3D 0xffffffffa03548a0 <sctp_generate_autoclose_event>,
       data =3D 18446612184522414080,
       base =3D 0xffff880c2dbf4000,
       start_site =3D 0x0,
       start_comm =3D "\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000",
       start_pid =3D -1
     }},
   shutdown_last_sent_to =3D 0x0,
   shutdown_retries =3D 0,
   init_last_sent_to =3D 0x0,
   next_tsn =3D 1248969237,
   ctsn_ack_point =3D 1248969236,
   adv_peer_ack_point =3D 1248969236,
   highest_sacked =3D 318833522,
   fast_recovery_exit =3D 0,
   fast_recovery =3D 0 '\000',
   unack_data =3D 0,
   rtx_data_chunks =3D 0,
   rwnd =3D 114688,
   a_rwnd =3D 114688,
   rwnd_over =3D 0,
   rwnd_press =3D 0,
   sndbuf_used =3D 0,
   rmem_alloc =3D {
     counter =3D 0
   },
   wait =3D {
     lock =3D {
       raw_lock =3D {
         slock =3D 0
       }
     },
     task_list =3D {
       next =3D 0xffff880c27d9dea0,
       prev =3D 0xffff880c27d9dea0
     }
   },
   frag_point =3D 0,
   user_frag =3D 0,
   init_err_counter =3D 0,
   init_cycle =3D 0,
   default_stream =3D 0,
   default_flags =3D 0,
   default_ppid =3D 0,
   default_context =3D 0,
   default_timetolive =3D 0,
   default_rcv_context =3D 0,
   ssnmap =3D 0x0,
   outqueue =3D {
     asoc =3D 0xffff880c27d9d800,
     out_chunk_list =3D {
       next =3D 0xffff880c27d9dee8,
       prev =3D 0xffff880c27d9dee8
     },
     out_qlen =3D 0,
     error =3D 0,
     control_chunk_list =3D {
       next =3D 0xffff880c27d9df00,
       prev =3D 0xffff880c27d9df00
     },
     sacked =3D {
       next =3D 0xffff880c27d9df10,
       prev =3D 0xffff880c27d9df10
     },
     retransmit =3D {
       next =3D 0xffff880c27d9df20,
       prev =3D 0xffff880c27d9df20
     },
     abandoned =3D {
       next =3D 0xffff880c27d9df30,
       prev =3D 0xffff880c27d9df30
     },
     outstanding_bytes =3D 0,
     fast_rtx =3D 0 '\000',
     cork =3D 0 '\000',
     empty =3D 1 '\001',
     malloced =3D 0 '\000'
   },
   ulpq =3D {
     malloced =3D 0 '\000',
     pd_mode =3D 0 '\000',
     asoc =3D 0xffff880c27d9d800,
     reasm =3D {
       next =3D 0xffff880c27d9df58,
       prev =3D 0xffff880c27d9df58,
       qlen =3D 0,
       lock =3D {
         raw_lock =3D {
           slock =3D 0
         }
       }
     },
     lobby =3D {
       next =3D 0xffff880c27d9df70,
       prev =3D 0xffff880c27d9df70,
       qlen =3D 0,
       lock =3D {
         raw_lock =3D {
           slock =3D 0
         }
       }
     }
   },
   last_ecne_tsn =3D 0,
   last_cwr_tsn =3D 318833522,
   numduptsns =3D 0,
   autoclose =3D 0,
   addip_last_asconf =3D 0x0,
   asconf_ack_list =3D {
     next =3D 0xffff880c27d9dfa0,
     prev =3D 0xffff880c27d9dfa0
   },
   addip_chunk_list =3D {
     next =3D 0xffff880c27d9dfb0,
     prev =3D 0xffff880c27d9dfb0
   },
   addip_serial =3D 1248969237,
   endpoint_shared_keys =3D {
     next =3D 0xffff8808477a5360,
     prev =3D 0xffff8808477a5360
   },
   asoc_shared_key =3D 0x0,
   default_hmac_id =3D 0,
   active_key_id =3D 0,
   need_ecne =3D 0 '\000',
   temp =3D 0 '\000'
}
crash>
crash>
crash>
crash>
crash> sctp_association ffff880c27d9d800 |grep primary_path
     primary_path =3D 0x0,
crash>
