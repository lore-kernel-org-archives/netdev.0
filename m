From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Add basic offloading of
 unicast traffic
Date: Sat, 23 Sep 2017 11:58:01 +0200
Message-ID: <2c5fec6d-18b3-97e9-dd64-85560382d2f7@egil-hjelmeland.no>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no>
 <20170921094139.4250-3-privat@egil-hjelmeland.no>
 <20170921142127.GB27589@lunn.ch>
 <b27d2dd4-84e3-b930-a6fe-1e5b36a7d213@egil-hjelmeland.no>
 <20170922200810.GJ3470@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922200810.GJ3470@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 22. sep. 2017 22:08, skrev Andrew Lunn:
>>> I'm wondering how this is supposed to work. Please add a good comment
>>> here, since the hardware is forcing you to do something odd.
>>>
>>> Maybe it would be a good idea to save the STP state in chip.  And then
>>> when chip->is_bridged is set true, change the state in the hardware to
>>> the saved value?
>>>
>>> What happens when port 0 is added to the bridge, there is then a
>>> minute pause and then port 1 is added? I would expect that as soon as
>>> port 0 is added, the STP state machine for port 0 will start and move
>>> into listening and then forwarding. Due to hardware limitations it
>>> looks like you cannot do this. So what state is the hardware
>>> effectively in? Blocking? Forwarding?
>>>
>>> Then port 1 is added. You can then can respect the states. port 1 will
>>> do blocking->listening->forwarding, but what about port 0? The calls
>>> won't get repeated? How does it transition to forwarding?
>>>
>>>    Andrew
>>>
>>
>> I see your point with the "minute pause" argument. Although a bit
>> contrived use case, it is easy to fix by caching the STP state, as
>> you suggest. So I can do that.
> 
> I don't think it is contrived. I've done bridge configuration by hand
> for testing purposes. I've also set the forwarding delay to very small
> values, so there is a clear race condition here.
> 
>> How does other DSA HW chips handle port separation? Knowing that
>> could perhaps help me know what to look for.
> 
> They have better hardware :-)
> 
> Generally each port is totally independent. You can change the STP
> state per port without restrictions.
> 
We can indeed change the STP state per lan9303 port "without
restrictions".

The point is: Once both external ports are in "forwarding", I see no way
to prevent traffic flowing directly between the external ports.


>        Andrew
> 

Egil
