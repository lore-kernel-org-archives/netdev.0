From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Mon, 09 Mar 2015 09:51:35 -0700
Message-ID: <54FDCF97.3000601@gmail.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>	<20150309140241.GI502@gospo.home.greyhouse.net> <CAE4R7bBwtGbB6FjJbEBXieYNRrqGknsC2FRQ2s270ySeEYNerQ@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34104 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbCIQvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 12:51:37 -0400
Received: by paceu11 with SMTP id eu11so60030211pac.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 09:51:37 -0700 (PDT)
In-Reply-To: <CAE4R7bBwtGbB6FjJbEBXieYNRrqGknsC2FRQ2s270ySeEYNerQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 03/09/2015 09:16 AM, Scott Feldman wrote:
> On Mon, Mar 9, 2015 at 7:02 AM, Andy Gospodarek 
> <gospo@cumulusnetworks.com> wrote:
>> On Sat, Mar 07, 2015 at 10:15:35PM -0800, sfeldma@gmail.com
>> wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>> 
>>> On ip route print dump, label externally offloaded routes with
>>> "external". Offloaded routes are flagged with RTNH_F_EXTERNAL,
>>> a recent additon to net-next.  For example:
>>> 
>>> $ ip route default via 192.168.0.2 dev eth0 11.0.0.0/30 dev
>>> swp1  proto kernel  scope link  src 11.0.0.2 external 
>>> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20
>>> external 11.0.0.8/30 dev swp2  proto kernel  scope link  src
>>> 11.0.0.10 external 11.0.0.12/30 via 11.0.0.9 dev swp2  proto
>>> zebra  metric 20 external 12.0.0.2  proto zebra  metric 30
>>> external nexthop via 11.0.0.1  dev swp1 weight 1 nexthop via
>>> 11.0.0.9  dev swp2 weight 1 12.0.0.3 via 11.0.0.1 dev swp1
>>> proto zebra  metric 20 external 12.0.0.4 via 11.0.0.9 dev swp2
>>> proto zebra  metric 20 external 192.168.0.0/24 dev eth0  proto
>>> kernel  scope link  src 192.168.0.15
>>> 
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> 
>> You know we cannot have a thread about nomenclature without a
>> comment from me.  ;)
>> 
>> My only concern about 'external' is whether or not people will
>> gloss over it since many of the routes listed will be to networks
>> that actually are external to the system.  That namespace
>> collision could seem awkward if you are not a traditional
>> follower of this list. Listing an FDB entry as 'external' does
>> not have the same issue since all FDB entries are local to the
>> system, so I didn't even think about the potential when that set
>> was posted.
>> 
>> I would like to just call this 'hardware' since that is what we
>> appear to be using for offload and would make it clear to the
>> user that this route was in hardware as well as in the kernel.
>> I'd say the same for FDB entries, too.
>> 
>> Scott, you have lots of experience in both traditional and Linux
>> worlds, do you think my concern about confusion is unnecessary?
> 
> Votes so far: 1 for "external", 1 for "hardware", 1 for "offload"
> or "hw".
> 
> Good point about confusion wrt routes to non-local networks.

My $0.02, "hardware" seems most appropriate to me.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJU/c+XAAoJEOVv75VaS+3O26oQAJcXXV9zqKMbme8r3Cj0XdfQ
fMBPluam7f4ZLcio4x/AG41CMOp4Wr9tWwV9nz7HgOxJ5YvpWqYqMc75oLMQtC/z
Ze4x0kRIS/zuk/kGD/8Lkh/ZAykjGM9J5gf1CVh5UI0D9h1Z5SCz8dkHbEkqvy8j
Pf/nNH5gaZCyM9QCzirXeSZsxjUtulIHibQiVn0qYbV4NeX0hq7uYvRCJ0OIG+Hb
cYJFhp2s9Lp075QELxLQqlHuZMMtX8xzL3N83AhXyyAZdW+R/Z8tjutHQsHrTdEd
+ErObbVdV4794gQDqB5SnuV+yIVRaeW6crls3r56WIwJS7eM0BhYj0iQLRqX+bEq
HjdUaOp+J3SbssIeLqkItBNsMtuMQWqpdBvJfPVXmFAyHaWv7i6M1S6logrBd+RH
ro16bGKOX/s/i0UoNBmNFoXHItIeBpfgdPxldCekUXhbuBObx2cRPZFaAclg4eO/
LQGZALgShFrI25+fA+MlngybI8MmLk7gdASfKmlI7BNHcuMcLXomQZx009GOGdJM
VQTUugAksOTUa6wMVJaNzNvtw3rszZEHwSWK+qK43om/Jsk4/1/kc3JEwDt0aZvn
O7f4Yh4R3fjyWYOf5ynYXjBfG2UNrEJknkVRJb2Ui6k0nZ3xNqggV89BFi5U3uop
OqrY1HzqmPz+sjSVeSzK
=wyRn
-----END PGP SIGNATURE-----
