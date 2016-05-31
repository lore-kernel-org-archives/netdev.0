From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 3/5] bridge: add json support for bridge
 fdb show
Date: Tue, 31 May 2016 12:22:36 -0700
Message-ID: <CACcJQnT6i-zcJrVeow4TWRU7q5pLeo+JBo38LK9Ptjj=G7O3Mw@mail.gmail.com>
References: <1464410236-65044-4-git-send-email-roopa@cumulusnetworks.com> <20160531115955.4a45ff67@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	julien@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34527 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbcEaTXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 15:23:16 -0400
Received: by mail-qg0-f51.google.com with SMTP id p34so27067964qgp.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 12:23:16 -0700 (PDT)
In-Reply-To: <20160531115955.4a45ff67@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 11:59 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 27 May 2016 21:37:14 -0700
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> Sample output:
>> $bridge -j fdb show
>> [{
>>         "mac": "44:38:39:00:69:88",
>>         "dev": "swp2s0",
>>         "vlan": 2,
>>         "master": "br0",
>>         "state": "permanent"
>>     },{
>>         "mac": "00:02:00:00:00:01",
>>         "dev": "swp2s0",
>>         "vlan": 2,
>>         "master": "br0"
>>     },{
>>         "mac": "00:02:00:00:00:02",
>>         "dev": "swp2s1",
>>         "vlan": 2,
>>         "master": "br0"
>>     },{
>>         "mac": "44:38:39:00:69:89",
>>         "dev": "swp2s1",
>>         "master": "br0",
>>         "state": "permanent"
>>     },{
>>         "mac": "44:38:39:00:69:89",
>>         "dev": "swp2s1",
>>         "vlan": 2,
>>         "master": "br0",
>>         "state": "permanent"
>>     },{
>>         "mac": "44:38:39:00:69:88",
>>         "dev": "br0",
>>         "master": "br0",
>>         "state": "permanent"
>>     }
>>     ]
>
> In most JSON I have seen, the output would be:
>
> {
>   "fdb" : [
>      {
>          "mac": "44:38:39:00:69:88",
>          "dev": "swp2s0",
>          "vlan": 2,
>          "master": "br0",
>          "state": "permanent"
>      },
> ...
>    ]
> }
>
> I.e never a bare array.
>
Yes Stephen, Adding an extra level would be one way to force the
format to json-object. And that would definitely be the way to do it
if we ever added a top level json dump - something like - "bridge -j
show".

But in the case of "bridge -j fdb show" that level is redundant. To be
consistent we would have to add that extra level to all json dumps
(even if they were already objects; such as the "bridge -j vlan
show").The google json style guide recommends against adding hierarchy
unless needed. And it is not that uncommon in java to have a
json-array of objects for e.g. http://json-schema.org/example1.html
talks about a schema that is an "array of products".

What do you recommend?
