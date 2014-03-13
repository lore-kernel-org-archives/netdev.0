From: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Patch 1/2] IB/mlx5: Implementation of PCI error handler
Date: Thu, 13 Mar 2014 10:51:46 -0500
Message-ID: <5321D412.1040501@linux.vnet.ibm.com>
References: <20140312034219.637916521@linux.vnet.ibm.com> <20140312034512.065218504@linux.vnet.ibm.com> <1394649252.23624.36.camel@deadeye.wl.decadent.org.uk> <20140313064521.GH20224@mtldesk30> <5321CAD3.2070301@linux.vnet.ibm.com> <20140313154002.GA28066@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140313154002.GA28066@mtldesk30>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 3/13/2014 10:40 AM, Eli Cohen wrote:
> On Thu, Mar 13, 2014 at 10:12:19AM -0500, Carol Soto wrote:
>> In mlx4 code, I do not recall a timeout for commands this big. So
>> the reason in mlx5 is 2 hrs is just for
>> debugging purposes? So if for any reason a command hang then the
>> user can not remove this module
>> for the next 2 hrs?
>>
> Hi Carol,
> well I haven't seen any such case with latest firmware releases.
> Anyway, 10 msec is really too short timeout value since there are
> commands that can take more than that (e.g. memory registartion of
> regions larger then 512 MB - though this will be changed soon). I
> wonder what was the original motivation and have you been able to
> simulate PCI errors and see this in action.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Hi Eli,

The motivation to reduce that timeout is that if there is a process in 
the middle of a HW command
in the middle of the PCI error, I probably did not want to wait 2hrs 
since the command will never complete
since the card is dead. Now you are right, I forgot the case of big 
memory registration where commands can
take longer than that. Do you have an idea of what is the longest time 
that a command can take in mlx5?


Carol


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
