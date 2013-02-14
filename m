From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: failure when attempting to build vmci_transport on net-next
Date: Thu, 14 Feb 2013 11:50:11 +0200
Message-ID: <511CB353.3000704@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>
To: Andy king <acking@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:52105 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757097Ab3BNJuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 04:50:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy & Co

I didn't manage to get the VMWARE_VMCI_VSOCKETS directive to be set, 
unless I added the below patch, and
once that done got the tons of errors below, am I doing something wrong?

Or.

diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index b5fa7e4..620982c 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -15,6 +15,9 @@ config VSOCKETS
           To compile this driver as a module, choose M here: the module
           will be called vsock. If unsure, say N.

+config VMWARE_VMCI
+       def_bool y
+
  config VMWARE_VMCI_VSOCKETS
         tristate "VMware VMCI transport for Virtual Sockets"
         depends on VSOCKETS && VMWARE_VMCI


>  CC [M]  net/vmw_vsock/vmci_transport.o
> In file included from net/vmw_vsock/vmci_transport.c:41:
> net/vmw_vsock/vmci_transport_notify.h:20:33: error: 
> linux/vmw_vmci_defs.h: No such file or directory
> net/vmw_vsock/vmci_transport_notify.h:21:32: error: 
> linux/vmw_vmci_api.h: No such file or directory
> In file included from net/vmw_vsock/vmci_transport_notify.h:24,
>                  from net/vmw_vsock/vmci_transport.c:41:
> net/vmw_vsock/vmci_transport.h:66: error: field ?dg? has incomplete type
> net/vmw_vsock/vmci_transport.h:76: error: field ?handle? has 
> incomplete type
> net/vmw_vsock/vmci_transport.h:110: error: field ?dg_handle? has 
> incomplete type
> net/vmw_vsock/vmci_transport.h:112: error: field ?qp_handle? has 
> incomplete type
> net/vmw_vsock/vmci_transport.c:47: warning: ?struct vmci_event_data? 
> declared inside parameter list
> net/vmw_vsock/vmci_transport.c:47: warning: its scope is only this 
> definition or declaration, which is probably not what you want
> net/vmw_vsock/vmci_transport.c:50: warning: ?struct vmci_event_data? 
> declared inside parameter list
> net/vmw_vsock/vmci_transport.c:80: error: variable 
> ?vmci_transport_stream_handle? has initializer but incomplete type
> net/vmw_vsock/vmci_transport.c:80: error: ?VMCI_INVALID_ID? undeclared 
> here (not in a function)
> net/vmw_vsock/vmci_transport.c:80: warning: excess elements in struct 
> initializer
> net/vmw_vsock/vmci_transport.c:80: warning: (near initialization for 
> ?vmci_transport_stream_handle?)
> net/vmw_vsock/vmci_transport.c:81: warning: excess elements in struct 
> initializer
> net/vmw_vsock/vmci_transport.c:81: warning: (near initialization for 
> ?vmci_transport_stream_handle?)
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_error_to_vsock_error?:
> net/vmw_vsock/vmci_transport.c:104: error: ?VMCI_ERROR_NO_MEM? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:104: error: (Each undeclared identifier 
> is reported only once
> net/vmw_vsock/vmci_transport.c:104: error: for each function it 
> appears in.)
> net/vmw_vsock/vmci_transport.c:107: error: 
> ?VMCI_ERROR_DUPLICATE_ENTRY? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:108: error: ?VMCI_ERROR_ALREADY_EXISTS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:111: error: ?VMCI_ERROR_NO_ACCESS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:114: error: ?VMCI_ERROR_NO_RESOURCES? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:117: error: 
> ?VMCI_ERROR_INVALID_RESOURCE? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:120: error: ?VMCI_ERROR_INVALID_ARGS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:137: error: parameter 9 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_packet_init?:
> net/vmw_vsock/vmci_transport.c:142: error: implicit declaration of 
> function ?vmci_make_handle?
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:210: error: parameter 9 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?__vmci_transport_send_control_pkt?:
> net/vmw_vsock/vmci_transport.c:216: error: type of formal parameter 9 
> is incomplete
> net/vmw_vsock/vmci_transport.c:217: error: implicit declaration of 
> function ?vmci_datagram_send?
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:230: error: parameter 6 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_reply_control_pkt_fast?:
> net/vmw_vsock/vmci_transport.c:243: error: type of formal parameter 9 
> is incomplete
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:254: error: parameter 7 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_control_pkt_bh?:
> net/vmw_vsock/vmci_transport.c:266: error: type of formal parameter 9 
> is incomplete
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:276: error: parameter 7 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_control_pkt?:
> net/vmw_vsock/vmci_transport.c:297: error: type of formal parameter 9 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_reset_bh?:
> net/vmw_vsock/vmci_transport.c:312: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:312: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_send_reset?:
> net/vmw_vsock/vmci_transport.c:323: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:323: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_negotiate?:
> net/vmw_vsock/vmci_transport.c:333: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:333: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_negotiate2?:
> net/vmw_vsock/vmci_transport.c:343: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:343: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:347: error: parameter 2 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_qp_offer?:
> net/vmw_vsock/vmci_transport.c:352: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:356: error: parameter 2 (?handle?) has 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_send_attach?:
> net/vmw_vsock/vmci_transport.c:361: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_reply_reset?:
> net/vmw_vsock/vmci_transport.c:370: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:370: error: type of formal parameter 6 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_invalid_bh?:
> net/vmw_vsock/vmci_transport.c:379: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:379: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_wrote_bh?:
> net/vmw_vsock/vmci_transport.c:388: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:388: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_send_read_bh?:
> net/vmw_vsock/vmci_transport.c:397: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:397: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_send_wrote?:
> net/vmw_vsock/vmci_transport.c:405: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:405: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_send_read?:
> net/vmw_vsock/vmci_transport.c:413: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:413: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_waiting_write?:
> net/vmw_vsock/vmci_transport.c:422: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:422: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_waiting_read?:
> net/vmw_vsock/vmci_transport.c:431: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:431: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_shutdown?:
> net/vmw_vsock/vmci_transport.c:441: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:441: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_conn_request?:
> net/vmw_vsock/vmci_transport.c:450: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:450: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_send_conn_request2?:
> net/vmw_vsock/vmci_transport.c:459: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:459: error: type of formal parameter 7 
> is incomplete
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_is_trusted?:
> net/vmw_vsock/vmci_transport.c:507: error: implicit declaration of 
> function ?vmci_is_context_owner?
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_allow_dgram?:
> net/vmw_vsock/vmci_transport.c:519: error: implicit declaration of 
> function ?vmci_context_get_priv_flags?
> net/vmw_vsock/vmci_transport.c:520: error: 
> ?VMCI_PRIVILEGE_FLAG_RESTRICTED? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_queue_pair_alloc?:
> net/vmw_vsock/vmci_transport.c:544: error: implicit declaration of 
> function ?vmci_qpair_alloc?
> net/vmw_vsock/vmci_transport.c:547: error: 
> ?VMCI_PRIVILEGE_FLAG_TRUSTED? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:548: error: ?VMCI_ERROR_NO_ACCESS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:554: error: ?VMCI_NO_PRIVILEGE_FLAGS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:568: error: expected declaration 
> specifiers or ?...? before ?vmci_datagram_recv_cb?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_datagram_create_hnd?:
> net/vmw_vsock/vmci_transport.c:578: error: implicit declaration of 
> function ?vmci_datagram_create_handle_priv?
> net/vmw_vsock/vmci_transport.c:579: error: 
> ?VMCI_PRIVILEGE_FLAG_TRUSTED? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:580: error: ?recv_cb? undeclared (first 
> use in this function)
> net/vmw_vsock/vmci_transport.c:583: error: ?VMCI_ERROR_NO_ACCESS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:584: error: implicit declaration of 
> function ?vmci_datagram_create_handle?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_recv_dgram_cb?:
> net/vmw_vsock/vmci_transport.c:615: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:616: error: ?VMCI_ERROR_NO_ACCESS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:618: error: implicit declaration of 
> function ?VMCI_DG_SIZE?
> net/vmw_vsock/vmci_transport.c:630: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_recv_stream_cb?:
> net/vmw_vsock/vmci_transport.c:667: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c:674: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:675: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:676: error: ?VMCI_ERROR_NO_ACCESS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:680: error: ?VMCI_ERROR_INVALID_ARGS? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:707: error: ?VMCI_ERROR_NOT_FOUND? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:759: error: ?VMCI_ERROR_NO_MEM? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:785: warning: ?struct vmci_event_data? 
> declared inside parameter list
> net/vmw_vsock/vmci_transport.c:783: error: conflicting types for 
> ?vmci_transport_peer_attach_cb?
> net/vmw_vsock/vmci_transport.c:45: note: previous declaration of 
> ?vmci_transport_peer_attach_cb? was here
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_peer_attach_cb?:
> net/vmw_vsock/vmci_transport.c:791: error: implicit declaration of 
> function ?vmci_event_data_const_payload?
> net/vmw_vsock/vmci_transport.c:791: warning: assignment makes pointer 
> from integer without a cast
> net/vmw_vsock/vmci_transport.c:807: error: implicit declaration of 
> function ?vmci_handle_is_equal?
> net/vmw_vsock/vmci_transport.c:808: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_handle_detach?:
> net/vmw_vsock/vmci_transport.c:826: error: implicit declaration of 
> function ?vmci_handle_is_invalid?
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:861: warning: ?struct vmci_event_data? 
> declared inside parameter list
> net/vmw_vsock/vmci_transport.c:859: error: conflicting types for 
> ?vmci_transport_peer_detach_cb?
> net/vmw_vsock/vmci_transport.c:48: note: previous declaration of 
> ?vmci_transport_peer_detach_cb? was here
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_peer_detach_cb?:
> net/vmw_vsock/vmci_transport.c:867: warning: assignment makes pointer 
> from integer without a cast
> net/vmw_vsock/vmci_transport.c:869: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:880: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c: At top level:
> net/vmw_vsock/vmci_transport.c:889: warning: ?struct vmci_event_data? 
> declared inside parameter list
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_recv_connecting_server?:
> net/vmw_vsock/vmci_transport.c:1126: error: storage size of ?handle? 
> isn?t known
> net/vmw_vsock/vmci_transport.c:1165: error: implicit declaration of 
> function ?vmci_event_subscribe?
> net/vmw_vsock/vmci_transport.c:1165: error: 
> ?VMCI_EVENT_QP_PEER_DETACH? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1168: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c:1185: error: ?VMCI_QPFLAG_ATTACH_ONLY? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1186: error: ?VMCI_QPFLAG_LOCAL? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1228: error: type of formal parameter 2 
> is incomplete
> net/vmw_vsock/vmci_transport.c:1126: warning: unused variable ?handle?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_recv_connecting_client_negotiate?:
> net/vmw_vsock/vmci_transport.c:1373: error: storage size of ?handle? 
> isn?t known
> net/vmw_vsock/vmci_transport.c:1384: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1436: error: 
> ?VMCI_EVENT_QP_PEER_ATTACH? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1439: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c:1444: error: 
> ?VMCI_EVENT_QP_PEER_DETACH? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1455: error: ?VMCI_QPFLAG_LOCAL? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1470: error: type of formal parameter 2 
> is incomplete
> net/vmw_vsock/vmci_transport.c:1491: error: implicit declaration of 
> function ?vmci_event_unsubscribe?
> net/vmw_vsock/vmci_transport.c:1497: error: implicit declaration of 
> function ?vmci_qpair_detach?
> net/vmw_vsock/vmci_transport.c:1373: warning: unused variable ?handle?
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_socket_init?:
> net/vmw_vsock/vmci_transport.c:1589: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_destruct?:
> net/vmw_vsock/vmci_transport.c:1629: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_release?:
> net/vmw_vsock/vmci_transport.c:1644: error: implicit declaration of 
> function ?vmci_datagram_destroy_handle?
> net/vmw_vsock/vmci_transport.c:1645: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_dgram_bind?:
> net/vmw_vsock/vmci_transport.c:1666: error: ?VMCI_FLAG_ANYCID_DG_HND? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1671: warning: passing argument 4 of 
> ?vmci_transport_datagram_create_hnd? from incompatible pointer type
> net/vmw_vsock/vmci_transport.c:566: note: expected ?struct vmci_handle 
> *? but argument is of type ?struct sock *?
> net/vmw_vsock/vmci_transport.c:1671: error: too many arguments to 
> function ?vmci_transport_datagram_create_hnd?
> net/vmw_vsock/vmci_transport.c:1672: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_dgram_enqueue?:
> net/vmw_vsock/vmci_transport.c:1689: error: ?VMCI_MAX_DG_PAYLOAD_SIZE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:1696: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1700: error: implicit declaration of 
> function ?VMCI_DG_PAYLOAD?
> net/vmw_vsock/vmci_transport.c:1700: warning: passing argument 1 of 
> ?memcpy_fromiovec? makes pointer from integer without a cast
> include/linux/socket.h:307: note: expected ?unsigned char *? but 
> argument is of type ?int?
> net/vmw_vsock/vmci_transport.c:1702: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1704: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1706: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1713: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_dgram_dequeue?:
> net/vmw_vsock/vmci_transport.c:1746: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1748: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1759: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1770: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c:1770: error: dereferencing pointer to 
> incomplete type
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_dgram_allow?:
> net/vmw_vsock/vmci_transport.c:1786: error: 
> ?VMCI_UNITY_PBRPC_REGISTER? undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_stream_dequeue?:
> net/vmw_vsock/vmci_transport.c:1830: error: implicit declaration of 
> function ?vmci_qpair_peekv?
> net/vmw_vsock/vmci_transport.c:1832: error: implicit declaration of 
> function ?vmci_qpair_dequev?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_stream_enqueue?:
> net/vmw_vsock/vmci_transport.c:1840: error: implicit declaration of 
> function ?vmci_qpair_enquev?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_stream_has_data?:
> net/vmw_vsock/vmci_transport.c:1845: error: implicit declaration of 
> function ?vmci_qpair_consume_buf_ready?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_stream_has_space?:
> net/vmw_vsock/vmci_transport.c:1850: error: implicit declaration of 
> function ?vmci_qpair_produce_free_space?
> net/vmw_vsock/vmci_transport.c: In function 
> ?vmci_transport_get_local_cid?:
> net/vmw_vsock/vmci_transport.c:2055: error: implicit declaration of 
> function ?vmci_get_context_id?
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_init?:
> net/vmw_vsock/vmci_transport.c:2102: error: ?VMCI_FLAG_ANYCID_DG_HND? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:2105: error: too many arguments to 
> function ?vmci_transport_datagram_create_hnd?
> net/vmw_vsock/vmci_transport.c:2106: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c:2111: error: ?VMCI_EVENT_QP_RESUMED? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:2130: error: 
> ?vmci_transport_stream_handle? has an incomplete type
> net/vmw_vsock/vmci_transport.c: In function ?vmci_transport_exit?:
> net/vmw_vsock/vmci_transport.c:2137: error: 
> ?vmci_transport_stream_handle? has an incomplete type
> net/vmw_vsock/vmci_transport.c:2139: error: 
> ?vmci_transport_stream_handle? has an incomplete type
> net/vmw_vsock/vmci_transport.c:2139: error: ?VMCI_SUCCESS? undeclared 
> (first use in this function)
> net/vmw_vsock/vmci_transport.c:2141: error: ?VMCI_INVALID_HANDLE? 
> undeclared (first use in this function)
> net/vmw_vsock/vmci_transport.c:2141: error: 
> ?vmci_transport_stream_handle? has an incomplete type
> make[2]: *** [net/vmw_vsock/vmci_transport.o] Error 1
> make[1]: *** [net/vmw_vsock] Error 2
> make: *** [net] Error 2
