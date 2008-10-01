From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 18:15:26 +0200
Message-ID: <48E3A21E.3060504@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org> <48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com> <1222872885.23573.64.camel@iris.sw.ru> <48E394D2.5090709@fr.ibm.com> <48E397C1.6050407@openvz.org> <48E3998D.4040709@fr.ibm.com> <48E39A7A.8090800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:44989 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbYJAQPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:15:38 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id m91GFbKZ008201
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 16:15:37 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91GFb9p3211312
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:15:37 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91GFaqe029343
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:15:37 +0100
In-Reply-To: <48E39A7A.8090800@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Pavel Emelyanov wrote:
>>>> Yes per namespace, I agree.
>>>>
>>>> If the option is controlled by the parent and it is done by sysctl, you 
>>>> will have to make proc/sys per namespace like Pavel did with /proc/net, no ?
>>> /proc/sys is already per namespace actually ;) Or what did you mean by that?
>>
>> Effectively I was not clear :)
>>
>> I meant, you can not access /proc/sys from outside the namespace like 
>> /proc/net which can be followed up by /proc/<pid>/net outside the namespace.
> 
> Ah! I've got it. Well, I think after Al Viro finishes with sysctl
> rework this possibility will appear, but Denis actually persuaded me
> in his POV - if we do want to disable shared sockets we *can* do this
> by putting containers in proper mount namespaces of chroot environments.

And I agree with this point. But :)

  1 - the current behaviour is full isolation. Shall we/can we change 
that without taking into account there are perhaps some people using 
this today ? I don't know.

  2 - I wish to launch a non chrooted application inside a namespace, 
sharing the file system without sharing the af_unix sockets, because I 
don't want the application running inside the container overlap with the 
socket af_unix of another container. I prefer to detect a collision with 
a strong isolation and handle it manually (remount some part of the fs 
for example).

  3 - I would like to be able to reduce this isolation (your point) to 
share the af_unix socket for example to use /dev/klog or something else.

I don't know how much we can consider the point 1, 2 pertinent, but 
disabling 3 lines of code via a sysctl with strong isolation as default 
and having a process unsharing the namespace in userspace and changing 
this value to less isolation is not a big challenge IMHO :)
