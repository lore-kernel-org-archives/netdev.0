From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Fwd: bug report: iproute2 policer parsing broken
Date: Sun, 22 Oct 2017 11:17:45 -0400
Message-ID: <38a6bc8e-675e-10f9-c15c-8fd41b20415a@mojatatu.com>
References: <6c0937de-c8a2-c25f-4fbf-545ba2ea5abd@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lucas Bates <lucasb@mojatatu.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:53092 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdJVPRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 11:17:48 -0400
Received: by mail-it0-f44.google.com with SMTP id j140so3342437itj.1
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 08:17:48 -0700 (PDT)
In-Reply-To: <6c0937de-c8a2-c25f-4fbf-545ba2ea5abd@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


forgot to cc netdev...

cheers,
jamal

-------- Forwarded Message --------
Subject: bug report: iproute2 policer parsing broken
Date: Sun, 22 Oct 2017 10:59:07 -0400
From: Jamal Hadi Salim <jhs@mojatatu.com>
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger 
<stephen@networkplumber.org>, Jiri Pirko <jiri@resnulli.us>
CC: Lucas Bates <lucasb@mojatatu.com>


It seems policer parsing with conform-exceed is broken.
I have verified this with a few actions.
git bisect indicates things were working before refactoring
into tc-utils.c - Unfortunately I dont have time to dig.
There seem to be two issues:

1) Has to do with whether you have space before or after "/"

#doesnt work
sudo $TC actions add action police rate 1kbit burst 90k \
conform-exceed  A /B
#doesnt work
sudo $TC actions add action police rate 1kbit burst 90k \
conform-exceed  A/B
#doesnt work
sudo $TC actions add action police rate 1kbit burst 90k \
conform-exceed  A/ B
#works
sudo $TC actions add action police rate 1kbit burst 90k \
conform-exceed  A / B

I tried a few actions but focussed on the "goto chain" and
"jump" actions.

2) specifying and index with "goto chain" but maybe consistent
across other actions

#works
sudo $TC actions add action police rate 1kbit burst 90k conform-exceed 
pipe / goto chain 111

#doesnt work
sudo $TC actions add action police rate 1kbit burst 90k conform-exceed 
pipe / goto chain 111 index 111

I may be able to get to it around netdev2.2 time if nobody else does.

cheers,
jamal
