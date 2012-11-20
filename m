From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] net/tipc: can delete checking: (if_local_len > TIPC_MAX_IF_NAME)
 || (if_peer_len  > TIPC_MAX_IF_NAME)
Date: Tue, 20 Nov 2012 12:08:41 +0800
Message-ID: <50AB0249.20802@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:37770 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab2KTEHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 23:07:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller:

  at net/tipc/link.c:212,213, we can delete the check (if_local_len > TIPC_MAX_IF_NAME) and (if_peer_len  > TIPC_MAX_IF_NAME)
  for the total buffer length is no more than TIPC_MAX_IF_NAME, already (at line 182..186).

  suggest to modify it, although it is minor.

thanks.


 167 static int link_name_validate(const char *name,
 168                                 struct tipc_link_name *name_parts)
 169 {
 170         char name_copy[TIPC_MAX_LINK_NAME];
 171         char *addr_local;
 172         char *if_local;
 173         char *addr_peer;
 174         char *if_peer;
 175         char dummy;
 176         u32 z_local, c_local, n_local;
 177         u32 z_peer, c_peer, n_peer;
 178         u32 if_local_len;
 179         u32 if_peer_len;
 180 
 181         /* copy link name & ensure length is OK */
 182         name_copy[TIPC_MAX_LINK_NAME - 1] = 0;
 183         /* need above in case non-Posix strncpy() doesn't pad with nulls */
 184         strncpy(name_copy, name, TIPC_MAX_LINK_NAME);
 185         if (name_copy[TIPC_MAX_LINK_NAME - 1] != 0)
 186                 return 0;
 187 
 188         /* ensure all component parts of link name are present */
 189         addr_local = name_copy;
 190         if_local = strchr(addr_local, ':');
 191         if (if_local == NULL)
 192                 return 0;
 193         *(if_local++) = 0;
 194         addr_peer = strchr(if_local, '-');
 195         if (addr_peer == NULL)
 196                 return 0;
 197         *(addr_peer++) = 0;
 198         if_local_len = addr_peer - if_local;
 199         if_peer = strchr(addr_peer, ':');
 200         if (if_peer == NULL)
 201                 return 0;
 202         *(if_peer++) = 0;
 203         if_peer_len = strlen(if_peer) + 1;
 204 
 205         /* validate component parts of link name */
 206         if ((sscanf(addr_local, "%u.%u.%u%c",
 207                     &z_local, &c_local, &n_local, &dummy) != 3) ||
 208             (sscanf(addr_peer, "%u.%u.%u%c",
 209                     &z_peer, &c_peer, &n_peer, &dummy) != 3) ||
 210             (z_local > 255) || (c_local > 4095) || (n_local > 4095) ||
 211             (z_peer  > 255) || (c_peer  > 4095) || (n_peer  > 4095) ||
 212             (if_local_len <= 1) || (if_local_len > TIPC_MAX_IF_NAME) ||
 213             (if_peer_len  <= 1) || (if_peer_len  > TIPC_MAX_IF_NAME))
 214                 return 0;
 215 
 216         /* return link name components, if necessary */
 217         if (name_parts) {
 218                 name_parts->addr_local = tipc_addr(z_local, c_local, n_local);
 219                 strcpy(name_parts->if_local, if_local);
 220                 name_parts->addr_peer = tipc_addr(z_peer, c_peer, n_peer);
 221                 strcpy(name_parts->if_peer, if_peer);
 222         }
 223         return 1;
 224 }



-- 
Chen Gang

Asianux Corporation
