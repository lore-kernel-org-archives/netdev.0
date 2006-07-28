From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 6/8] NetLabel: CIPSOv4 integration
Date: Fri, 28 Jul 2006 14:10:20 -0400
Message-ID: <44CA530C.9040803@hp.com>
References: <20060622224910.885573000@flek.zko.hp.com>	 <20060622225410.521216000@flek.zko.hp.com> <1154087670.5165.36.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:10382 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161208AbWG1SKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:10:21 -0400
To: hadi@cyberus.ca
In-Reply-To: <1154087670.5165.36.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> On Thu, 2006-22-06 at 18:49 -0400, paul.moore@hp.com wrote:
>>+/**
>>+ * netlbl_cipsov4_rcv - Process incoming NetLabel packets
>>+ * @skb: the NETLINK buffer
>>+ * @msg: pointer to the start of the NetLabel data
>>+ *
>>+ * Description:
>>+ * This function is reponsibile for reading all of the incoming CIPSO V4
>>+ * NetLabel traffic and dispatching it to the correct CIPSO V4 functions.
>>+ *
>>+ */
>>+void netlbl_cipsov4_rcv(const struct sk_buff *skb, const unsigned char *msg)
>>+{
>>+	int ret_val;
>>+	struct netlbl_cipsov4_msghdr *nl_cv4_hdr;
>>+
>>+	if (nlmsg_len((struct nlmsghdr *)skb->data) <
>>+	    sizeof(struct netlbl_cipsov4_msghdr)) {
>>+		netlbl_cipsov4_send_ack(skb, EINVAL);
>>+		return;
>>+	}
>>+
>>+	nl_cv4_hdr = (struct netlbl_cipsov4_msghdr *)msg;
>>+	switch (nl_cv4_hdr->opcode) {
>>+	case NL_CV4_ADD:
> 
> Could you not have had all these NL_CV4_CMDs as just TLVs?
> This is just the classical way of how we do things.
> This would allow you to send multiple cmds in one message as well as 
> very easily add new ones in the future.

I think you are looking at an older patchset, which is most likely my
fault for not clearly marking each patch set with a datestamp or version
number.  I will fix that in next release.

Anyway, back to your comment - this function no longer exists in the
current patchset.  All of the different "commands" specified by NL_CV4_*
are now "operations" registered with the genetlink interface.  It's not
the TLV solution you mention but it seems to be inline with how the
generic netlink interface works.

> BTW, can you please repost your latest changes to netdev?

Yes I will, but not much has changed from my last patchset posted to
netdev (although quite a bit has changed since the patchset you are
looking at).  I'm in the middle of moving/unpacking right now so it may
not get posted until sometime this weekend, although I try for today.

-- 
paul moore
linux security @ hp
