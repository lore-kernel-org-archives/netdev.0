From: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [net-next RFC v2 9/9] doc: Add LSM / BPF Checmate docs
Date: Mon, 29 Aug 2016 09:50:34 -0700
Message-ID: <2cc1f477-f06d-b5b4-09f0-d2e786ee2952@infradead.org>
References: <20160829114756.GA20918@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160829114756.GA20918-I4sfFR6g6EicJoAdRrHjTrzMkBWIpU9tytq7g7fCXyjEk0E+pv7Png@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/16 04:47, Sargun Dhillon wrote:
> This adds documentation on how to operate, and develop against the
> Checmate LSM and Cgroup controller.
> 
> Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
> ---
>  Documentation/security/Checmate.txt | 54 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 54 insertions(+)
>  create mode 100644 Documentation/security/Checmate.txt
> 
> diff --git a/Documentation/security/Checmate.txt b/Documentation/security/Checmate.txt
> new file mode 100644
> index 0000000..d409785
> --- /dev/null
> +++ b/Documentation/security/Checmate.txt
> @@ -0,0 +1,54 @@
> +--- What is Checmate? ---
> +
> +Checmate is a flexible programmable, extensible minor LSM that's coupled with
> +cgroups and BPF. It is designed to enforce container-specific policies. By
> +default, it does not enforce any policies. It is selectable at build time
> +with CONFIG_SECURITY_CHECMATE, and it is controlled through the unified cgroups
> +controller hierarchy.
> +
> +# How to use Checmate
> +In order to use Checmate, you have to enable the controller on the cgroup2
> +hierarchy. In order to prevent a centralized configuration daemon from mounting
> +Checmate on the V1 hierarchy you may want to add 'cgroup_no_v1=checmate' to your
> +boot command line.
> +
> +Enabling the controller:
> +	mount -t cgroup2 none $MOUNT_POINT
> +	cd $MOUNT_POINT
> +	echo +checmate > cgroup.subtree_control
> +
> +Once you do this, immediate children of this node on the hierarchy will have a
> +number of control files that begin with 'checmate.'. Each of these is mapped
> +to an LSM hook by the same name. If you read the file, it will return the
> +number of filters attached to that given hook. Details of the hooks can be
> +found in lsm_hooks.h.
> +
> +All tasks which are members of a cgroup will have no only the checmate filters

s/no/not/

> +at that level enforced, but all levels above as well. If there is a need
> +to exempt a specific sub-cgroup, a program can use current_task_under_cgroup
> +along with a bpf map.
> +
> +## Adding filters:
> +If you would like to add a filter, you must compile a BPF_PROG_TYPE_CHECMATE BPF
> +program. You can then write the '%d\n' formatted version of the BPF program
> +file descriptor to the relevant control file.
> +
> +## Removing filters:
> +If you would like to remove a specific filter, you can write the negative file
> +descriptor of the BPF program to the control file (a la '-%d\n'). If you would
> +like to do this, then it is recommended that you pin your programs.
> +
> +If you would like to remove all filters from a specific hook, simply write '0'
> +to the control file. During normal operation, you shouldn't have the bpf syscall
> +return '0' for a given program, please take proper precautions to work around
> +this.
> +
> +# Caveats
> +## Hook Limit:
> +Each hook is limited to having MAX_CHECMATE_INSTANCES (32) hooks per level
> +in the hierarchy. The write call will return ENOSPC if you hit this condition.
> +
> +## CGroup v2 interaction with CGroup v1:
> +Because the cgroups subsystem is in transition, using the net_prio or the
> +net_classid v1 cgroups will render Checmate inoperable on all network
> +hooks that inspect sockets.
> \ No newline at end of file



-- 
~Randy
