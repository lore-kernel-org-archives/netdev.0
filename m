From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 18:06:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB5F605.1010507@candelatech.com>
References: <Pine.GSO.4.30.0210222033210.24323-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Mon, 21 Oct 2002, Ben Greear wrote:
> 
> 
>>jamal wrote:
>>
>>>Patch looks fine except for the 300 number. What are you smoking?
>>>Please retain the original value.
>>
>>The original value was 300, what do you want it to be?
>>
> 
> 
> Ok, i take back what i said then. Your patch is not that useful.
> For some reason i thought you were introducing NET_CORE_DEV_WEIGHT
> which happens to already exist with default value of 64.
> The value you put out MUST be the same as netdev_max_backlog in order
> to be fair to non-NAPI devices.
> Any change to one must be reflected to the other. So a useful patch
> will try to shadow NET_CORE_MAX_BACKLOG to that value and allow only
> changes to happen to NET_CORE_MAX_BACKLOG; i.e no need for two separate
> parameters.

Actually, with the changes the way they are, if you have a backlog value
of 300, and the first NAPI driver reads 300 packets, then all the rest of the
NAPI drivers will just throw away packets because the max-backlog has
already been hit (if I understand things correctly).

If we make the backlog big enough to handle a large burst of incomming
traffic w/out dropping them, then the first NAPI driver can hog a very
large amount of CPU because its budget is now huge.  The rest of
the devices in the poll loop will not be serviced in time, and will
drop packets (I saw this when testing out the 4-port tulip driver with
the NAPI patch).

Ben

> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
