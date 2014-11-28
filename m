From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Fri, 28 Nov 2014 07:57:00 -0500
Message-ID: <5478711C.8080700@mojatatu.com>
References: <5474ABF0.60901@mojatatu.com> <5474AE9B.6000500@intel.com> <5474B353.10802@mojatatu.com> <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com> <547546C5.3060207@mojatatu.com> <CAE4R7bA2VPZ3tm2MrsXAm4XfNX0TguT=vUma-3HrZSu98hBGyA@mail.gmail.com> <5475B952.2080500@mojatatu.com> <CAE4R7bAM+orLXdEn0qCu2rKj+W5_681RHmvgW4CY5H7jZ0ijfQ@mail.gmail.com> <54771598.80806@mojatatu.com> <CAE4R7bDzxo1xY-MHzqtQ70s+nf+3dkWhr7neV-atk1YkMP3KJw@mail.gmail.com> <20141127215529.GA17784@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	"jasowang@redhat.com" <jasow
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:57546 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaK1M5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 07:57:05 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so5645063igi.6
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 04:57:04 -0800 (PST)
In-Reply-To: <20141127215529.GA17784@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 16:55, Jiri Pirko wrote:
> Thu, Nov 27, 2014 at 09:59:37PM CET, sfeldma@gmail.com wrote:
>> Ya right now the driver just doesn't call br_fdb_external_learn_add()
>> if LEARNING_SYNC is not set.  It's a port driver setting so it seems
>> fine to handle it in the port driver.  You could move the check up to
>> br_fdb_external_learn_add(), but then you have an extra call every 1s
>> for each fdb entry being refreshed.  (1s or whatever the refresh
>> frequency is).  Easier to avoid this overhead and make the decision at
>> the source.
>
> I have been thinking about moving the check into bridge code, it to make
> it there as well as in drivers. This is easily changeable on demenad
> later though, so I left this for now.
>

It seems more comfortable to move to the core if you are doing polling
with timers... i.e you kick it per-offload via some timer. The arming
being done by the setting of LEARNING_SYNC
There are cases where all this is done via interrupts. i.e the hardware
will issue an interrupt only then do you poll..

Maybe Scott's approach is the correct one. I am indifferent to be
honest, these are some of those things that can be easily refactored
as more hardware shows up.

cheers,
jamal
