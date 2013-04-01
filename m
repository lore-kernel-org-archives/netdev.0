From: Ani Sinha <linuxdev@anirban.org>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sun, 31 Mar 2013 20:17:39 -0700
Message-ID: <CAOQZsUjbx9fHtjexmpfGCETRjVJU7QOBJcng6ndT1nFaZKmf5w@mail.gmail.com>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	<CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
	<1364708664.5113.139.camel@edumazet-glaptop>
	<CAOQZsUj71vX-71S4WhJUmerh5VhtheacXVCkGKpyFEHTG9WBgA@mail.gmail.com>
	<1364785789.5113.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:59358 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534Ab3DADRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 23:17:39 -0400
Received: by mail-ie0-f176.google.com with SMTP id x14so1932482ief.7
        for <netdev@vger.kernel.org>; Sun, 31 Mar 2013 20:17:39 -0700 (PDT)
In-Reply-To: <1364785789.5113.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 31, 2013 at 8:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-03-31 at 18:24 -0700, Ani Sinha wrote:
>
>> So in "another_round", if pt_prev is null at the end of the function
>> (not sure if this can actually happen in reality, but from the code it
>> looks like a possibility), the dropped counts will get incremented.
>>
>
> If packets are dropped, we increment rx_dropped.
>
> Nothing special with vlan, its the same with non tagged packets.
>
> So far so good.
>

Correct. Now if you combine the two cases, we increment the rx count
for tagged packets in  vlan_do_receive() and then in "another_round",
if pt_prev is null, we also increment the rx_dropped.

Now I have no issue with that _except_ it seems that when we report
the counter values in /proc, we do so in a way that for a tagged
packet, it seems that there might be a case where we combine the two
numbers so that the same packet results in a single increment of
receive and dropped counters at the same time (see my very first
email).

Hence my confusion.
