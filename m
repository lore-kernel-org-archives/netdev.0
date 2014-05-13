From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Problem with iflink in netns
Date: Tue, 13 May 2014 08:39:45 -0700
Message-ID: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:56007 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaEMPjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 11:39:48 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so428928pab.1
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 08:39:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There have been a couple of bugzilla reports already about cases where a macvlan
or vlan is moved into another namespace. In these cases the parent device ifindex (iflink)
is no longer valid.


Normally it is not a big issue, until another device is created using the ifindex
of the parent

Does anyone have a suggested fix? Marking iflink as 0 won't work then the devices no
longer appear as slaves. Another possibility would be to make block creation of device
where ifindex matches existing iflink of other devices; but this would slow down device
creation.
 

The bugs come in as ip command bugs, but obviously the issue is in the kernel.

https://bugzilla.kernel.org/show_bug.cgi?id=66691
https://bugzilla.kernel.org/show_bug.cgi?id=75911
