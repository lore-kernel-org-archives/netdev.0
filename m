From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Sat, 10 Jan 2009 08:14:19 -0800
Message-ID: <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>
	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
	 <496476FD.8090209@cn.fujitsu.com>
	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
	 <49682921.4020100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:58582 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbZAJQOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 11:14:24 -0500
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id n0AGEMOv008164
	for <netdev@vger.kernel.org>; Sat, 10 Jan 2009 08:14:22 -0800
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by zps77.corp.google.com with ESMTP id n0AGEJdw009018
	for <netdev@vger.kernel.org>; Sat, 10 Jan 2009 08:14:19 -0800
Received: by rv-out-0506.google.com with SMTP id f6so10241027rvb.9
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2009 08:14:19 -0800 (PST)
In-Reply-To: <49682921.4020100@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2009 at 8:50 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>>
>> For checking the "children" list, you can just lock
>> ipaddr_subsys.hierarchy_mutex.
>>
>
> Unfortunately hierarchy_mutex can't be used here, since hierarchy_mutex
> doesn't protect subsys's create() method, and the create() will access
> parent cgroup's data.
>

But that can be solved by putting a spinlock in the ipaddr_cgroup
structure and taking it in the write handler (and the connect/bind
handlers, which should also be using RCU), and taking the parent
structure's lock before copying from it in the create callback. No
need for something as heavy as cgroup_lock().

Paul
