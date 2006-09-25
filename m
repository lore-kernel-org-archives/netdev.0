From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 5/6] NetLabel: rework the Netlink attribute handling (part
 2)
Date: Mon, 25 Sep 2006 11:42:03 -0400
Message-ID: <4517F8CB.1030707@hp.com>
References: <20060921165703.251871000@hp.com> <20060921170337.744519000@hp.com> <20060925094311.GO18349@postel.suug.ch> <4517E3F1.6050809@hp.com> <20060925150625.GP18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, sds@epoch.ncsc.mil,
	jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:35529 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751027AbWIYPmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 11:42:07 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060925150625.GP18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Paul Moore <paul.moore@hp.com> 2006-09-25 10:13
> 
>>>>-	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
>>>>+	switch (doi_def->type) {
>>>>+	case CIPSO_V4_MAP_STD:
>>>>+		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVLLST);
>>>>+		if (nla_a == NULL) {
>>>>+			ret_val = -ENOMEM;
>>>>+			goto list_failure_lock;
>>>>+		}
>>>>+		for (iter = 0;
>>>>+		     iter < doi_def->map.std->lvl.local_size;
>>>>+		     iter++) {
>>>>+			if (doi_def->map.std->lvl.local[iter] ==
>>>>+			    CIPSO_V4_INV_LVL)
>>>>+				continue;
>>>
>>>
>>>Can you estimate the number of entries being dumped here and in the cat
>>>list below?
>>>
>>
>>It's too hard to come up with a reasonable estimate without going
>>through the entire list before hand, which in previous messages (might
>>of been off-list) you pointed out as a bad thing.  If you would prefer I
>>can go back to doing it that way?
>  
> Sorry, I didn't make myself clear. I didn't mean to estimate the
> size of the message. The way you're doing it right now is perfectly
> fine. I'm interested in a estimate on how many items are being dumped
> in practice. Less than 1K or a couple of K?
> 
> High order allocations are likely to fail if under pressure while
> using dumpit() allows to reuse memory ressources.

It's hard to get a good idea of the likely usage scenario as I'm not
sure how users will want to configure NetLabel.  However, there is a
possibility of this growing larger than NLMSG_GOODSIZE, which makes
things a bit more difficult.  From what I can see dumpit() requires the
message be within NLMSG_GOODSIZE while a doit() response can be of
arbitrary length; this is why I chose a doit() response.  Even if the
system is under memory pressure I think a failure here is okay as this
is not what I would consider a critical message.

-- 
paul moore
linux security @ hp
