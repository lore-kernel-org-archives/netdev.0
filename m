From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 3/5] bridge: add json support for bridge
 fdb show
Date: Fri, 17 Jun 2016 12:07:07 -0700
Message-ID: <CACcJQnSfjcA0TXwqUg+HYdbM_4LAYUQ+4xmj6Fd24nvbjNMdrg@mail.gmail.com>
References: <1464410236-65044-4-git-send-email-roopa@cumulusnetworks.com>
 <20160531115955.4a45ff67@xeon-e3> <CACcJQnT6i-zcJrVeow4TWRU7q5pLeo+JBo38LK9Ptjj=G7O3Mw@mail.gmail.com>
 <CACcJQnTqkOXpuhRGM1tpJH-sEdMxS3Voux46tphi+pdydTU_4w@mail.gmail.com> <20160617120427.1e8ba9a3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33831 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcFQTHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 15:07:53 -0400
Received: by mail-qk0-f181.google.com with SMTP id s186so94802684qkc.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 12:07:47 -0700 (PDT)
In-Reply-To: <20160617120427.1e8ba9a3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 12:04 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 17 Jun 2016 11:04:54 -0700
> Anuradha Karuppiah <anuradhak@cumulusnetworks.com> wrote:
>
>> On Tue, May 31, 2016 at 12:22 PM, Anuradha Karuppiah
>> <anuradhak@cumulusnetworks.com> wrote:
>> > On Tue, May 31, 2016 at 11:59 AM, Stephen Hemminger
>> > <stephen@networkplumber.org> wrote:
>> >> On Fri, 27 May 2016 21:37:14 -0700
>> >> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> >>
>> >>> Sample output:
>> >>> $bridge -j fdb show
>> >>> [{
>> >>>         "mac": "44:38:39:00:69:88",
>> >>>         "dev": "swp2s0",
>> >>>         "vlan": 2,
>> >>>         "master": "br0",
>> >>>         "state": "permanent"
>> >>>     },{
>> >>>         "mac": "00:02:00:00:00:01",
>> >>>         "dev": "swp2s0",
>> >>>         "vlan": 2,
>> >>>         "master": "br0"
>> >>>     },{
>> >>>         "mac": "00:02:00:00:00:02",
>> >>>         "dev": "swp2s1",
>> >>>         "vlan": 2,
>> >>>         "master": "br0"
>> >>>     },{
>> >>>         "mac": "44:38:39:00:69:89",
>> >>>         "dev": "swp2s1",
>> >>>         "master": "br0",
>> >>>         "state": "permanent"
>> >>>     },{
>> >>>         "mac": "44:38:39:00:69:89",
>> >>>         "dev": "swp2s1",
>> >>>         "vlan": 2,
>> >>>         "master": "br0",
>> >>>         "state": "permanent"
>> >>>     },{
>> >>>         "mac": "44:38:39:00:69:88",
>> >>>         "dev": "br0",
>> >>>         "master": "br0",
>> >>>         "state": "permanent"
>> >>>     }
>> >>>     ]
>> >>
>> >> In most JSON I have seen, the output would be:
>> >>
>> >> {
>> >>   "fdb" : [
>> >>      {
>> >>          "mac": "44:38:39:00:69:88",
>> >>          "dev": "swp2s0",
>> >>          "vlan": 2,
>> >>          "master": "br0",
>> >>          "state": "permanent"
>> >>      },
>> >> ...
>> >>    ]
>> >> }
>> >>
>> >> I.e never a bare array.
>> >>
>> > Yes Stephen, Adding an extra level would be one way to force the
>> > format to json-object. And that would definitely be the way to do =
it
>> > if we ever added a top level json dump - something like - "bridge =
-j
>> > show".
>> >
>> > But in the case of "bridge -j fdb show" that level is redundant. T=
o be
>> > consistent we would have to add that extra level to all json dumps
>> > (even if they were already objects; such as the "bridge -j vlan
>> > show").The google json style guide recommends against adding hiera=
rchy
>> > unless needed. And it is not that uncommon in java to have a
>> > json-array of objects for e.g. http://json-schema.org/example1.htm=
l
>> > talks about a schema that is an "array of products".
>> >
>> > What do you recommend?
>>
>> Hi Stephen,
>> We did a bit more digging around and found that other folks use json
>> output with top level array as well. Here=E2=80=99s a docker network=
s json
>> output sample -
>>
>> vagrant@host-21 ~ $ docker network inspect red
>> [
>>     {
>>         "Name": "red",
>>         "Id": "d2fff9bafd7564c4012aa49f322fcd8f5743cc5ceb465dc218af5=
ba22c920981",
>>         "Scope": "global",
>>         "Driver": "overlay",
>>         "EnableIPv6": false,
>>         "IPAM": {
>>             "Driver": "default",
>>             "Options": {},
>>             "Config": [
>>                 {
>>                     "Subnet": "10.252.20.0/24"
>>                 }
>>             ]
>>         },
>>         "Internal": false,
>>         "Containers": {
>>             "c92084c1ebfb4f0a601537298c273078862207e3b564787ddd6ef56=
4efbaca47":
>> {
>>                 "Name": "ctr21",
>>                 "EndpointID":
>> "e7468a70f13f1ea7b15445ab555374892ac41f71ea9023af1d9ede668bfd8742",
>>                 "MacAddress": "02:42:0a:fc:14:03",
>>                 "IPv4Address": "10.252.20.3/24",
>>                 "IPv6Address": ""
>>             },
>>             "ep-9bfc004b4046512f0f0104fe022d3686f5237ae08475741f8d52=
0552cbb63d45":
>> {
>>                 "Name": "ctr22",
>>                 "EndpointID":
>> "9bfc004b4046512f0f0104fe022d3686f5237ae08475741f8d520552cbb63d45",
>>                 "MacAddress": "02:42:0a:fc:14:02",
>>                 "IPv4Address": "10.252.20.2/24",
>>                 "IPv6Address": ""
>>             }
>>         },
>>         "Options": {},
>>         "Labels": {}
>>     }
>> ]
>>
>> Adding an additional namespace to all the json outputs (just to avoi=
d
>> a top-level json-array for some) seems redundant. If a namespace is
>> needed for other reasons we can definitely add it. So we think it
>> would be better to just go with the top-level json-array for a
>> list/set-of-objects outputs.
>
> Ok, resubmit. I never claimed to be a JSON expert :=3D)

will do :)
