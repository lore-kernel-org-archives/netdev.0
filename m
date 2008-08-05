From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [LTP] [PATCH 0/0] Traffic control cgroups subsystem
Date: Tue, 5 Aug 2008 11:06:30 -0700
Message-ID: <166fe7950808051106m3fd9751aw32f8d577cf24d1e9@mail.gmail.com>
References: <Pine.LNX.4.64.0807241628270.30437@ranjit.corp.google.com>
	 <bb33bcf20807241648s7685c91akfd6c50c23242f031@mail.gmail.com>
	 <1217934045.15385.1.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ltp-list <ltp-list@lists.sourceforge.net>,
	Sudhir <sudhirkumarmalik@in.ibm.com>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, menage@google.com, kaber@trash.net,
	"Balbir Singh" <balbir@linux.vnet.ibm.com>
To: subrata@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:54025 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758773AbYHESGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 14:06:48 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out3.google.com with ESMTP id m75I6W2b017898
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 19:06:32 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by wpaz37.hot.corp.google.com with ESMTP id m75I6V24021070
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 11:06:31 -0700
Received: by an-out-0708.google.com with SMTP id c36so461949ana.36
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 11:06:31 -0700 (PDT)
In-Reply-To: <1217934045.15385.1.camel@subratamodak.linux.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 5, 2008 at 4:00 AM, Subrata Modak
<subrata@linux.vnet.ibm.com> wrote:
>
> On Fri, 2008-07-25 at 05:18 +0530, Subrata Modak wrote:
>> Hi Ranjit,
>>
>> Good to see these Traffic control patches for the Linux kernel. Let me
>> take this opportunity to convey that we have:
>>
>> 1) CPU & Memory controller test cases (the corresponding features are
>> already in mainline kernel),
>> 2) The I/O bandwidth controller test cases (corresponding
>> infrastructure proposed by Andrea, but still not in any kernel tree)
>>
>> in LTP (http://ltp.sourceforge.net/).
>>
>> Could you kindly let me know if you have developed similar test cases
>> for your Traffic control features, and, if they can be contributed to
>> LTP under GPL.
>
> Ranjit,
>
> Would you like to tell us something on the test cases for this ?

Subrata,
  We have some internal test cases but not under LTP. Let me take a
look at the existing LTP infrastructure and see if these can be ported
over.

-Thanks,
Ranjit


>
> Regards--
> Subrata
>
>>
>> Regards--
>> Subrata
>>
>> On Fri, Jul 25, 2008 at 5:03 AM, Ranjit Manomohan <ranjitm@google.com>
>> wrote:
>>         [Take 4] incorporated additional comments from Patrick McHardy
>>
>>         This patch provides a simple resource controller (cgroup_tc)
>>         based on the
>>         cgroups infrastructure to manage network traffic. The
>>         cgroup_tc resource
>>         controller can be used to schedule and shape traffic belonging
>>         to the task(s)
>>         in a particular cgroup.
>>
>>         The implementation consists of two parts:
>>
>>         1) A resource controller (cgroup_tc) that is used to associate
>>         packets from
>>           a particular task belonging to a cgroup with a traffic
>>         control class id (
>>           tc_classid). This tc_classid is propagated to all sockets
>>         created by tasks
>>           in the cgroup and will be used for classifying packets at
>>         the link layer.
>>
>>         2) A new traffic control classifier (cls_cgroup) that can
>>         classify packets
>>           based on the tc_classid field in the socket to specific
>>         destination classes.
>>
>>         An example of the use of this resource controller would be to
>>         limit
>>         the traffic from all tasks from a file_server cgroup to
>>         100Mbps. We could
>>         achieve this by doing:
>>
>>         # make a cgroup of file transfer processes and assign it a
>>         arbitrary unique
>>         # classid of 0x1234 - this will be used later to direct
>>         packets.
>>         mkdir -p /dev/cgroup
>>         mount -t cgroup tc -otc /dev/cgroup
>>         mkdir /dev/cgroup/file_transfer
>>         echo 0x1234 > /dev/cgroup/file_transfer/tc.classid
>>         echo $PID_OF_FILE_XFER_PROCESS
>>         > /dev/cgroup/file_transfer/tasks
>>
>>         # Now create a HTB class that rate limits traffic to 100mbits
>>         and attach
>>         # a filter to direct all traffic from cgroup file_transfer to
>>         this new class.
>>         tc qdisc add dev eth0 root handle 1: htb
>>         tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit
>>         ceil 100mbit
>>         tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1
>>         cgroup value 0x1234 classid 1:10
>>
>>         Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
>>
>>         ---
>>         --
>>         To unsubscribe from this list: send the line "unsubscribe
>>         linux-kernel" in
>>         the body of a message to majordomo@vger.kernel.org
>>         More majordomo info at
>>          http://vger.kernel.org/majordomo-info.html
>>         Please read the FAQ at  http://www.tux.org/lkml/
>>
>>
>>
>> --
>> Regards & Thanks--
>> Subrata
>> -------------------------------------------------------------------------
>> This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
>> Build the coolest Linux based applications with Moblin SDK & win great prizes
>> Grand prize is a trip for two to an Open Source event anywhere in the world
>> http://moblin-contest.org/redirect.php?banner_id=100&url=/
>> _______________________________________________ Ltp-list mailing list Ltp-list@lists.sourceforge.net https://lists.sourceforge.net/lists/listinfo/ltp-list
>
>
