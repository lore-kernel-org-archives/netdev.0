From: "Subrata Modak" <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/0] Traffic control cgroups subsystem
Date: Fri, 25 Jul 2008 05:18:38 +0530
Message-ID: <bb33bcf20807241648s7685c91akfd6c50c23242f031@mail.gmail.com>
References: <Pine.LNX.4.64.0807241628270.30437@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0231952480=="
Cc: ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Sudhir <sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: "Ranjit Manomohan" <ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807241628270.30437-VvtfKOzWLfxSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0231952480==
Content-Type: multipart/alternative;
	boundary="----=_Part_135826_10670055.1216943318277"

------=_Part_135826_10670055.1216943318277
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Ranjit,

Good to see these Traffic control patches for the Linux kernel. Let me take
this opportunity to convey that we have:

1) CPU & Memory controller test cases (the corresponding features are
already in mainline kernel),
2) The I/O bandwidth controller test cases (corresponding infrastructure
proposed by Andrea, but still not in any kernel tree)

in LTP (http://ltp.sourceforge.net/).

Could you kindly let me know if you have developed similar test cases for
your Traffic control features, and, if they can be contributed to LTP under
GPL.

Regards--
Subrata

On Fri, Jul 25, 2008 at 5:03 AM, Ranjit Manomohan <ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
wrote:

> [Take 4] incorporated additional comments from Patrick McHardy
>
> This patch provides a simple resource controller (cgroup_tc) based on the
> cgroups infrastructure to manage network traffic. The cgroup_tc resource
> controller can be used to schedule and shape traffic belonging to the
> task(s)
> in a particular cgroup.
>
> The implementation consists of two parts:
>
> 1) A resource controller (cgroup_tc) that is used to associate packets from
>   a particular task belonging to a cgroup with a traffic control class id (
>   tc_classid). This tc_classid is propagated to all sockets created by
> tasks
>   in the cgroup and will be used for classifying packets at the link layer.
>
> 2) A new traffic control classifier (cls_cgroup) that can classify packets
>   based on the tc_classid field in the socket to specific destination
> classes.
>
> An example of the use of this resource controller would be to limit
> the traffic from all tasks from a file_server cgroup to 100Mbps. We could
> achieve this by doing:
>
> # make a cgroup of file transfer processes and assign it a arbitrary unique
> # classid of 0x1234 - this will be used later to direct packets.
> mkdir -p /dev/cgroup
> mount -t cgroup tc -otc /dev/cgroup
> mkdir /dev/cgroup/file_transfer
> echo 0x1234 > /dev/cgroup/file_transfer/tc.classid
> echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks
>
> # Now create a HTB class that rate limits traffic to 100mbits and attach
> # a filter to direct all traffic from cgroup file_transfer to this new
> class.
> tc qdisc add dev eth0 root handle 1: htb
> tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
> tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 cgroup value
> 0x1234 classid 1:10
>
> Signed-off-by: Ranjit Manomohan <ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> ---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Regards & Thanks--
Subrata

------=_Part_135826_10670055.1216943318277
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div dir="ltr">Hi Ranjit,<br><br>Good to see these Traffic control patches for the Linux kernel. Let me take this opportunity to convey that we have:<br><br>1) CPU &amp; Memory controller test cases (the corresponding features are already in mainline kernel),<br>
2) The I/O bandwidth controller test cases (corresponding infrastructure proposed by Andrea, but still not in any kernel tree)<br><br> in LTP (<a href="http://ltp.sourceforge.net/">http://ltp.sourceforge.net/</a>).<br><br>
Could you kindly let me know if you have developed similar test cases for your Traffic control features, and, if they can be contributed to LTP under GPL.<br><br>Regards--<br>Subrata<br><br><div class="gmail_quote">On Fri, Jul 25, 2008 at 5:03 AM, Ranjit Manomohan &lt;<a href="mailto:ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org">ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">[Take 4] incorporated additional comments from Patrick McHardy<br>
<br>
This patch provides a simple resource controller (cgroup_tc) based on the<br>
cgroups infrastructure to manage network traffic. The cgroup_tc resource<br>
controller can be used to schedule and shape traffic belonging to the task(s)<br>
in a particular cgroup.<br>
<br>
The implementation consists of two parts:<br>
<br>
1) A resource controller (cgroup_tc) that is used to associate packets from<br>
 &nbsp; a particular task belonging to a cgroup with a traffic control class id (<br>
 &nbsp; tc_classid). This tc_classid is propagated to all sockets created by tasks<br>
 &nbsp; in the cgroup and will be used for classifying packets at the link layer.<br>
<br>
2) A new traffic control classifier (cls_cgroup) that can classify packets<br>
 &nbsp; based on the tc_classid field in the socket to specific destination classes.<br>
<br>
An example of the use of this resource controller would be to limit<br>
the traffic from all tasks from a file_server cgroup to 100Mbps. We could<br>
achieve this by doing:<br>
<br>
# make a cgroup of file transfer processes and assign it a arbitrary unique<br>
# classid of 0x1234 - this will be used later to direct packets.<br>
mkdir -p /dev/cgroup<br>
mount -t cgroup tc -otc /dev/cgroup<br>
mkdir /dev/cgroup/file_transfer<br>
echo 0x1234 &gt; /dev/cgroup/file_transfer/tc.classid<br>
echo $PID_OF_FILE_XFER_PROCESS &gt; /dev/cgroup/file_transfer/tasks<br>
<br>
# Now create a HTB class that rate limits traffic to 100mbits and attach<br>
# a filter to direct all traffic from cgroup file_transfer to this new class.<br>
tc qdisc add dev eth0 root handle 1: htb<br>
tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit<br>
tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 cgroup value 0x1234 classid 1:10<br>
<br>
Signed-off-by: Ranjit Manomohan &lt;<a href="mailto:ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org">ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org</a>&gt;<br>
<br>
---<br>
<font color="#888888">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel&quot; in<br>
the body of a message to <a href="mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a><br>
More majordomo info at &nbsp;<a href="http://vger.kernel.org/majordomo-info.html" target="_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at &nbsp;<a href="http://www.tux.org/lkml/" target="_blank">http://www.tux.org/lkml/</a><br>
</font></blockquote></div><br><br clear="all"><br>-- <br>Regards &amp; Thanks--<br>Subrata
</div>

------=_Part_135826_10670055.1216943318277--


--===============0231952480==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
--===============0231952480==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ltp-list mailing list
Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ltp-list

--===============0231952480==--
