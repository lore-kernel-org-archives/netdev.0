From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: idr_get_new_exact ?
Date: Mon, 20 Sep 2010 15:07:40 -0500
Message-ID: <4C97BF0C.6070809@opengridcomputing.com>
References: <AANLkTi=ZLupVyFR0e2v-TLpeNWdw1bVMZUAhgyxLJ7OV@mail.gmail.com> <20100920123140.f524de79.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Jean Delvare (PC drivers, core)" <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>,
	"Ben Dooks (embedded platforms)" <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ohad Ben-Cohen <ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100920123140.f524de79.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/20/2010 02:31 PM, Andrew Morton wrote:
> On Mon, 20 Sep 2010 16:11:31 +0200
> Ohad Ben-Cohen<ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>  wrote:
>
>    
>> Occasionally, drivers care about the value that idr associates with
>> their pointers.
>>
>> Today we have idr_get_new_above() which allocates a new idr entry
>> above or equal to a given starting id, but sometimes drivers need to
>> force an exact value.
>>
>> To overcome this small API gap, drivers are wrapping idr_get_new_above
>> and then either BUG_ON() or just call idr_remove() and returns -EBUSY
>> when idr allocates them an id which is different than their requested
>> value.
>>
>> There are only a handful of users who need this (see below. especially
>> note the i2c comment :), but it might be nice to have such an API (a
>> bit less of code, and a bit less error prone).
>>
>> Would something like the below be desirable/acceptable ?
>>      
> It seems OK to me - it's an improvement over what we have now.
>
>    

Looks ok to me also.  This is exactly what cxgb* needs.  IE the driver 
manages the ID space and never expects an idr insertion to fail because 
its already inserted.  That constitutes a driver bug (which is why the 
BUG_ON() is there :)).

Steve.
