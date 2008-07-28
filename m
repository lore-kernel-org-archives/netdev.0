From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC 2/2] TCP: Add TCP-AO support
Date: Mon, 28 Jul 2008 13:33:40 -0400 (EDT)
Message-ID: <20080728.133340.40841332.yoshfuji@linux-ipv6.org>
References: <396556a20807181922t32c05b86l335de10bd1106ab2@mail.gmail.com>
	<20080719.120721.88812679.yoshfuji@linux-ipv6.org>
	<396556a20807251434n300ca24bw833f51dc0a332676@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32973 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbYG1Rdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 13:33:33 -0400
In-Reply-To: <396556a20807251434n300ca24bw833f51dc0a332676@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <396556a20807251434n300ca24bw833f51dc0a332676@mail.gmail.com> (at Fri, 25 Jul 2008 14:34:00 -0700), "Adam Langley" <agl@imperialviolet.org> says:

> /* struct tcp_auth_op_key - add, delete or replace a key
>  * @tcpak_addr - the address of the host to which this key applies
>  * @tcpak_keynum - the number of this key.
>  * @tcpak_tx_keyid - the keyid of this key on the wire when transmitted
>  * @tcpak_keylen - length of the key, in bytes
>  * @tcpak_key - the key data follows this structure
>  */
> struct tcp_auth_op_key {
> 	struct __kernel_sockaddr_storage	tcpak_addr;
> 	__u16					tcpak_keynum;
> 	__u8					tcpak_tx_keyid;
> 	__u8					tcpak_keylen;
> 	__u8					tcpak_reserved[4];
> 	__u8					tcpak_key[0];
> };

Let's share layout between tcp_md5sig{} and tcp_auth_op_key{} like this:
struct tcp_auth_op_key {
	struct __kernel_sockaddr_storage        tcpak_addr;
	__u16					tcpak_keynum;
	__u16					tcpak_keylen;
	__u8					tcpak_tx_keyid;
	__u8					tcpak_reserved[3];
	__u8					tcpak_key[0];
};

Then we can share TCP_AUTH_KEY_SET and TCP_MD5SIG.

--yoshfuji
