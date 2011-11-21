From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 14:12:35 -0800
Message-ID: <20111121141235.71a5f8fd@nehalam.linuxnetplumber.net>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<1321911029-20707-6-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-6-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

There are lots of new global symbols created by this module.
Since C has no namespaces, a kernel module needs to in general
stick to one prefix and naming convention.

$ nm openvswitch.ko | grep -v ' U ' | grep -v ' [btrd] ' 
0000000000000000 D __this_module
00000000000028c6 T cleanup_module
0000000000001fe6 T dp_detach_port
0000000000000540 D dp_device_notifier
0000000000001cb5 T dp_name
0000000000002438 T dp_process_received_packet
00000000000023ae T dp_upcall
0000000000000000 D dp_vport_multicast_group
0000000000000774 T execute_actions
0000000000002c3a T flow_actions_alloc
0000000000002c9f T flow_alloc
0000000000002edf T flow_deferred_free
0000000000002ef6 T flow_deferred_free_acts
0000000000004310 T flow_exit
0000000000002f0d T flow_extract
0000000000002e1c T flow_free
00000000000039d9 T flow_from_nlattrs
0000000000003790 T flow_hash
00000000000042c7 T flow_init
0000000000003dfa T flow_metadata_from_nlattrs
0000000000002cde T flow_tbl_alloc
0000000000002d94 T flow_tbl_deferred_destroy
0000000000002e60 T flow_tbl_destroy
0000000000003936 T flow_tbl_expand
00000000000038ed T flow_tbl_insert
0000000000003873 T flow_tbl_lookup
0000000000002db4 T flow_tbl_next
00000000000039b6 T flow_tbl_remove
0000000000003e99 T flow_to_nlattrs
0000000000002bad T flow_used
0000000000002b5f T flow_used_time
0000000000000000 T init_module
0000000000004baa T internal_dev_get_vport
0000000000000270 R internal_vport_ops
0000000000004b8f T is_internal_dev
0000000000004bde T netdev_get_ifindex
0000000000004bcc T netdev_get_name
0000000000004e22 T netdev_get_vport
0000000000000510 R netdev_vport_ops
0000000000000220 R ovs_key_lens
0000000000002523 T ovs_vport_cmd_build_info
00000000000044c7 T vport_add
000000000000441b T vport_alloc
00000000000045c9 T vport_del
00000000000043b3 T vport_exit
00000000000044a2 T vport_free
00000000000046ce T vport_get_options
000000000000462d T vport_get_stats
000000000000438e T vport_init
00000000000043ca T vport_locate
000000000000476d T vport_receive
00000000000047de T vport_record_error
000000000000479e T vport_send
0000000000004572 T vport_set_options

I recommend that all non-static functions an data be prefixed with one
string (like ovs_).  
