From: John Fastabend <john.fastabend@gmail.com>
Subject: tc rsvp filter show broke
Date: Fri, 26 Sep 2014 10:41:25 -0700
Message-ID: <5425A545.1040907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33503 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042AbaIZRlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 13:41:36 -0400
Received: by mail-oi0-f52.google.com with SMTP id a141so8637641oig.39
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 10:41:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

Here is another strange 'tc' result that I think is a
bug. If it was intended I can't see why. Show filter
commands on rsvp classifiers only list the first entry?


# for i in {10..20}; do
tc filter add dev p3p2 protocol ip parent 8001: prio $i \
	rsvp session 12.0.0.$i ipproto udp classid 1:$i;
done

# tc filter show dev p3p2
filter parent 8001: protocol ip pref 10 rsvp
# tc filter show dev p3p2  prio 11
filter parent 8001: protocol ip rsvp
# tc filter show dev p3p2  prio 22

Although the entries must still be around because listing
the prio explicitly show the entries. Also the case where
the prio doesn't exist returns without any errors. A better
response might be 'EINVAL' or something.

This is on 3.16 so nothing to do with my changes. I'm
not sure I'll get a chance until Monday to look at it
so figured I'll document it here in case someone else has
a moment.

Thanks,
John


-- 
John Fastabend         Intel Corporation
