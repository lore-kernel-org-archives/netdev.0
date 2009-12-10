From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3  5/8] CAIF Protocol Stack
Date: Thu, 10 Dec 2009 14:05:13 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E0790311F113@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com> <4B13F5D3.6090009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <stefano.babic@babic.homelinux.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:62710 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759061AbZLJNiw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 08:38:52 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B13F5D3.6090009@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy.
Thank you for helping out on style issues, and my English writing.
As you probably have figured English is not my mother tongue.

Randy Dunlap wrote:
> sjur.brandeland@stericsson.com wrote:
>> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> what Patrick said:
> patch description should be here and each email subject should be
> different and describe what that patch does. Please read
> Documentation/SubmittingPatches. 
OK I'll read carefully through Submitting Patches. Do you recon this will be ok?
Subject: [PATCH X/Y] net-caif: Add CAIF Protocol Stack in net/caif/generic

>> +menuconfig CAIF
>> +	tristate "Enable CAIF support"
>> +	default n
>> +	---help---
> 
> Tell us what CAIF means, probably in the help text.

I have rephrased this a bit, what do you think about this:
[snip]
menuconfig CAIF
	tristate "Enable CAIF support"
	default n
	---help---
	The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
	connection-oriented MUX protocol developed by ST-Ericsson for use with its modems.

	Say Y (or M) here if you build for a phone product (e.g. Android) that uses
	CAIF as transport, if unsure say N. 

	If you select to build it as module then CAIF_SOCK and CAIF_NETDEV also needs to 
	be built as modules. You will also need to say yes to any CAIF physical devices that
	your platform requires.

	See Documentation/net/CAIF for a further explanation on how to use and configure CAIF.


>> +	default CAIF
>> +	---help---
>> +	Say Y if you will be using the CAIF based network device.
> 
> 	                           a (or any) CAIF-based
Changed to:
	Say Y if you will be using a CAIF based GPRS network device.

>> +	Say Y if you will be using the CAIF Sockets.
> 	drop "the" ----------------^^^
> s/mist/must/
OK, I'll fix this.
> 
>> +/**
>> + * func caif_create_skb - Creates a CAIF SKB buffer
> 
> Use documented/expected kernel-doc notation, please.  I.e., drop
> "func". 
I realize I have some work to do run kernel-doc and update formatting of 
comments. I'll try to find time for this before submitting next patch-set.
> 
> 
>> +
>> +module_init(caif_device_init);
>> +module_exit(caif_device_exit);
>> +
>> +
>> +
>> +
>> +
>> +
>> +
>> +
>> +
> 
> delete all of those trailing empty lines.
Yes I will, thanks.
> 
>> +/** Packet Receive Callback function called from CAIF Stack */
> 
> Do not use /** to begin comments that are not kernel-doc notation.
> (more found below, but deleted for now)
OK, thank you for pointing this out.
It seems like caif_socket.c has a number of style problems.
I'll try to go through the file more carefully before next patch-set.

> 
>> +static int caif_sktrecv_cb(struct layer *layr, struct cfpkt *pkt) {
> 
...
>> +	do {
>> +			ret = cf_sk->layer.dn->transmit(cf_sk->layer.dn,
>> +							&info, pkt);
> 
> odd indentation?
Yes, I'll update this.
> 
>> +
>> +static int setsockopt(struct socket *sock,
>> +			int lvl, int opt, char __user *ov, int ol) {
>> +	struct sock *sk = sock->sk;
>> +	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
>> +	struct caif_channel_opt confopt;
>> +	int res;
>> +
>> +	if (lvl != SOL_CAIF) {
>> +		CAIFLOG_TRACE("setsockopt bad level\n");
>> +			return -ENOPROTOOPT;
> 
> odd indentation.

And this.

> 
...
>> +	}
>> +
>> +	switch (opt) {
>> +	case CAIF_CHANNEL_OPT:
>> +		if (ol < sizeof(struct caif_channel_opt)) {
>> +			CAIFLOG_TRACE("setsockopt"
>> +					" CAIF_CHANNEL_CONFIG bad size\n");
>> +				return -EINVAL;
> 
> odd indentation.

and this,

> 
...
>>
>> +int caif_connect(struct socket *sock, struct sockaddr *uservaddr,
>> +	       int sockaddr_len, int flags)
>> +{
>> +	struct caifsock *cf_sk = NULL;
>> +	int result = -1;
>> +	int mode = 0;
>> +	int ret = -EIO;
>> +    struct sock *sk = sock->sk;
> 
> indent above line with tab, not spaces.

and this,

> 
...
>> +	lock_sock(&(cf_sk->sk));
>> +	/* NOTE: This is how the sock->sk structure is used all over the
>> linux +	 *       socket implementation. Since there is no locking
>> protecting +	 *       the sock->sk pointer, the linux socket
>> implementation do not +	 *       support multiple threads using the
>> same socket descriptor, +	 *       since if one of the threads close
>> the socket, the other +	 *       threads may end up accessing a
>> pointer to NULL. See for +	 *       instance sock_setsockopt in
>> net/socket.c, it uses sock->sk +	 *       without checking if its
>> value is NULL. */ 
> 
> 	/*
> 	 * Note: This is the Linux long comment
> 	 * style.  Please use it.
> 	 */

Yes, I will.

> 
>> +	/* The rest of the cleanup will be handled from the +	 *
>> caif_sock_destructor */ +}
> 
>> +/* This function is called when a socket is finally destructed. */
> 
>                                                        destroyed. */
> 

> 
...
>> +static struct chnl_net *find_device(char *name, bool
>> +remove_from_list) { +	struct list_head *list_node;
>> +	struct list_head *n;
>> +	struct chnl_net *dev = NULL;
>> +	struct chnl_net *tmp;
>> +	CAIFLOG_ENTER("");
>> +	spin_lock(&list_lock);
>> +	CAIFLOG_TRACE("[%s:%d] start looping \n", __func__, +		__LINE__);
>> +	list_for_each_safe(list_node, n, &chnl_net_list) { +		tmp =
>> +			list_entry(list_node, struct chnl_net, list_field);
> 
> Above doesn't need to be on 2 lines.

Agree, I'll fix this.

> 

Thank you Randy for your feedback, I appreciate it.

BR/Sjur
