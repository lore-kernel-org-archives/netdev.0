From: poma <pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: NETDEV WATCHDOG:  internal(r8152): transmit queue 0 timed out
Date: Wed, 04 Feb 2015 01:20:23 +0100
Message-ID: <54D165C7.2010306@gmail.com>
References: <m99j1v$n60$1@ger.gmane.org>	<54B8CAC2.6020406@gmail.com>	<0835B3720019904CB8F7AA43166CEEB2EE6935@RTITMBSV03.realtek.com.tw>	<54B8FF7E.2010901@gmail.com> <m9c8hl$2sd$1@ger.gmane.org> <54BA23CE.70001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Community support for Fedora users
	<users-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: sean darcy <seandarcy2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54BA23CE.70001-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17.01.2015 09:56, poma wrote:
> On 17.01.2015 00:57, sean darcy wrote:
>> On 01/16/2015 07:09 AM, poma wrote:
>>> On 16.01.2015 10:37, Hayes Wang wrote:
>>>>   poma [mailto:pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
>>>>> Sent: Friday, January 16, 2015 4:25 PM
>>>> [...]
>>>>>> This looks like a USB problem. Is there a way to get usb (or
>>>>>> NetworkManager) to reinitialize the driver when this happens?
>>>>>
>>>>> I would ask these people for advice, therefore.
>>>>
>>>> Our hw engineers need to analyse the behavior of the device.
>>>> However, I don't think you have such instrument to provide
>>>> the required information. If we don't know the reason, we
>>>> couldn't give you the proper solution. Besides, your solution
>>>> would work if and only if reloading the driver is helpful.
>>>>
>>>> The issue have to debug from the hardware, and I have no idea
>>>> about what the software could do before analysing the hw. Maybe
>>>> you could try the following driver first to check if it is useful.
>>>>
>>>> http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=2&PNid=13&PFid=56&Level=5&Conn=4&DownTypeID=3&GetDown=false
>>>>
>>>> Best Regards,
>>>> Hayes
>>>>
>>>
>>> Thanks for your response, Mr. Hayes.
>>>
>>> Mr. Sean, please download and check if "timeout" is still present with built RTL8153 module from REALTEK site, as Mr. Hayes proposed.
>>> http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=2&PNid=13&PFid=56&Level=5&Conn=4&DownTypeID=3&GetDown=false#2
>>> r8152.53-2.03.0.tar.bz2
>>>
>>> Procedure - should be equal for both, Fedora 21 & 20:
>>>
>>> $ uname -r
>>> 3.17.8-300.fc21.x86_64
>>>
>>> $ su -c 'yum install kernel-devel'
>>>
>>> $ tar xf r8152.53-2.03.0.tar.bz2
>>> $ cd r8152-2.03.0/
>>> $ make
>>> $ su
>>>
>>> # cp 50-usb-realtek-net.rules /etc/udev/rules.d/
>>> # udevadm trigger --action=add
>>>
>>> # modprobe -rv r8152
>>> # cp r8152.ko /lib/modules/$(uname -r)/updates/
>>> # depmod
>>> # modprobe -v r8152
>>>
>>>
>>> poma
>>>
>> OK. Did all that. Now to see if I get the same problem over the next 
>> couple of weeks.
>>
>> I'd never heard about the updates subfolder in modules. Very slick.
>>
>> But when I update the kernel, I get to do this again correct? How will I 
> 
> $ cd r8152-2.03.0/
> $ make clean
> $ make
> $ su
> 
> # cp r8152.ko /lib/modules/$(uname -r)/updates/
> # depmod
> # modprobe -v r8152
> 
> is part of the procedure necessary for a new i.e. an upgraded kernel.
> 
> 
>> know that this module has been incorporated in the running kernel. 
>> modinfo doesn't give any version info.
>>
> 
> $ modinfo r8152 -n
> 
> will show the module considered for loading.
> 
> 
>> BTW, I'm not sure what modprobe --dump-modversions is supposed to do, 
>> but it doesn't:
>>
>> #modprobe --dump-modversions r8152
>> modprobe: FATAL: Module r8152 not found.
>> # modprobe --dump-modversions r8152.ko
>> modprobe: FATAL: Module r8152.ko not found.
>> #lsmod | grep 8152
>> r8152                  49646  0
>>
> 
> "--dump-modversions" will probably show the same error for any module.
> 
> 
>> Thanks for all your help.
>>
>> sean
>>
> 
> YW
> 
> 
> 

Mr. Sean,
is your problem with r8152 resolved, are
"kernel: r8152 2-2:1.0 internal: Tx timeout"
still present?


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
