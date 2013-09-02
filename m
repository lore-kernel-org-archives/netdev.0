From: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Subject: Re: [PATCH v2 3/3] Send cgroup_path in SCM_CGROUP
Date: Mon, 2 Sep 2013 19:17:00 +0200
Message-ID: <CAPXgP120-PZHvEkAOgvUNkYYXnNfPt=SbxjRWY1hDXY9RWTJWQ@mail.gmail.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1377785602-10766-1-git-send-email-jkaluza@redhat.com>
	<1377785602-10766-4-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377785602-10766-4-git-send-email-jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 29, 2013 at 4:13 PM, Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Add new SCM type called SCM_CGROUP to send "cgroup_path" in SCM.
> This is useful for journald (systemd logging daemon) to get additional context
> with each log line received using UNIX socket.
>
> Signed-off-by: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

In many cases it's generally more useful to explain *why* something is
done, not *where* it is used. It makes it easier for people to match
the described problem to their own use-cases, where it possibly occurs
too. The problem this patch solves is very generic and not so much
specific to logging or the journal. Maybe something like this:

"Server-like processes in many cases need credentials and other
metadata of the peer, to decide if the calling process is allowed to
request a specific action, or the server just wants to log away this
type of information for auditing tasks.

The current practice to retrieve such process metadata is to look that
information up in procfs with the $PID received over SCM_CREDENTIALS.
This is sufficient for long-running tasks, but introduces a race which
cannot be worked around for short-living processes; the calling
process and all the information in /proc/$PID/ is gone before the
receiver of the socket message can look it up.

This introduces a new SCM type called SCM_CGROUP to allow the direct
attaching of "cgroup_path" to SCM, which is significantly more
efficient and will reliably avoid the race with the round-trip over
procfs."

Thanks,
Kay
