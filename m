From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 11:33:00 -0700
Message-ID: <42A0A25C.8000503@candelatech.com>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, jdmason@us.ibm.com,
        shemminger@osdl.org, hadi@cyberus.ca,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ronciak, John wrote:
>> It's not obvious that weight is to blame for frames dropped. I would 
>> look into RX ring size in relation to HW mitigation.
>> And of course if you system is very loaded the RX softirq gives room
>> for other jobs and frames get dropped
>>
> 
> With the same system (fairly high end with nothing major running on it)
> we got rid of the dropped frames by just reducing the weight for 64.  So
> the weight did have something to do with the dropped frames.  Maybe
> other factors as well, but in static tests like this it sure looks like
> the 64 value is wrong is some cases.

Is this implying that having the NAPI poll do less work per poll
of the driver actually increases performance?  I would have guessed that
the opposite would be true.

Maybe the poll is disabling the IRQs on the NIC for too long, or something
like that?

For e1000, are you using larger than the default 256 receive descriptors?
I have seen that increasing these descriptors helps decrease drops by
a small percentage.

Have you tried increasing the netdev-backlog setting to see if that
fixes the problem (while leaving the weight at the default)?

What packet sizes and speeds are you using for your tests?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
