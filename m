From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipt_MASQUERADE weirdness (consuming CPU cycles while not used)
Date: Mon, 25 May 2009 17:35:57 +0200
Message-ID: <4A1ABADD.7000806@trash.net>
References: <200905182219.30216.denys@visp.net.lb> <4A1596D4.6000708@netfilter.org> <200905212310.29661.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200905212310.29661.denys@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryschenko wrote:
> On Thursday 21 May 2009 21:00:52 Pablo Neira Ayuso wrote:
>> Denys Fedoryschenko wrote:
>>> I have loaded pppoe (1700 users). I test one rule for short time with -j
>>> MASQUERADE, then removed it and reset conntrack (conntrack -F). But still
>>> i can see it is consuming CPU even when it is not used in any rule. Even
>>> i reboot server and just load rules that dont have MASQUERADE, and just
>>> load module - it will start consuming CPU immediately.
>> Are you using 2.6.29 with any conntrack helper loaded? In that case this
>> fix is not in -stable yet.
>>
>> http://kerneltrap.org/mailarchive/linux-netdev/2009/4/8/5440564
>>
>>> 64811     3.7735  ipt_MASQUERADE           ipt_MASQUERADE          
>>> device_cmp
>> device_cmp() by nf_ct_iterate_cleanup() when NETDEV_DOWN event is
>> received. Weird, is your device going down quite often? Another
>> possibility is that there's some entry stuck in the conntrack table that
>> we cannot delete, perhaps we're leaking refcounts somewhere.
 >
> It is loaded pppoe server (2k interfaces), sure they are 
> appearing-disappearing non-stop. Thats maybe case, but weird that it is 
> consuming CPU time while module not used at all anywhere (no rules with 
> MASQUERADE).

It doesn't know that until it has iterated over the conntrack table
and looked at all the entries. We could add a module parameter to
disable the "autoclean" feature, but it seems easier to just not
load it if you don't actually need it.
