From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH iproute2] Replace BSD MAXPATHLEN by POSIX PATH_MAX
Date: Mon, 27 Jul 2015 10:12:44 +0200
Message-ID: <CAGm1_ksNS-hStXfpuSdvYKmsPvcwgO630WZQaT7+39OTBdfVfg@mail.gmail.com>
References: <20150726192532.GA17926@nyan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f41.google.com ([209.85.216.41]:34858 "EHLO
	mail-vn0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbbG0INE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:13:04 -0400
Received: by vnaa140 with SMTP id a140so28113048vna.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 01:13:03 -0700 (PDT)
In-Reply-To: <20150726192532.GA17926@nyan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 26, 2015 at 9:25 PM, Felix Janda <felix.janda@posteo.de> wrote:
> Prefer using the POSIX constant PATH_MAX instead of the legacy BSD
> derived MAXPATHLEN. The necessary includes for MAXPATHLEN and PATH_MAX
> are <sys/param.h> and <limits.h>, respectively.
>
> Signed-off-by: Felix Janda <felix.janda@posteo.de>

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

> ---
> This patch is identical except for title and commit message to the one
> with title "Use PATH_MAX instead of MAXPATHLEN".
> ---
>  ip/ipnetns.c    | 15 +++++++--------
>  lib/namespace.c | 11 ++++++-----
>  2 files changed, 13 insertions(+), 13 deletions(-)
>
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index 0c28f8a..3b704a4 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -4,7 +4,6 @@
>  #include <sys/wait.h>
>  #include <sys/inotify.h>
>  #include <sys/mount.h>
> -#include <sys/param.h>
>  #include <sys/syscall.h>
>  #include <stdio.h>
>  #include <string.h>
> @@ -437,7 +436,7 @@ static int is_pid(const char *str)
>  static int netns_pids(int argc, char **argv)
>  {
>         const char *name;
> -       char net_path[MAXPATHLEN];
> +       char net_path[PATH_MAX];
>         int netns;
>         struct stat netst;
>         DIR *dir;
> @@ -472,7 +471,7 @@ static int netns_pids(int argc, char **argv)
>                 return -1;
>         }
>         while((entry = readdir(dir))) {
> -               char pid_net_path[MAXPATHLEN];
> +               char pid_net_path[PATH_MAX];
>                 struct stat st;
>                 if (!is_pid(entry->d_name))
>                         continue;
> @@ -493,7 +492,7 @@ static int netns_pids(int argc, char **argv)
>  static int netns_identify(int argc, char **argv)
>  {
>         const char *pidstr;
> -       char net_path[MAXPATHLEN];
> +       char net_path[PATH_MAX];
>         int netns;
>         struct stat netst;
>         DIR *dir;
> @@ -537,7 +536,7 @@ static int netns_identify(int argc, char **argv)
>         }
>
>         while((entry = readdir(dir))) {
> -               char name_path[MAXPATHLEN];
> +               char name_path[PATH_MAX];
>                 struct stat st;
>
>                 if (strcmp(entry->d_name, ".") == 0)
> @@ -563,7 +562,7 @@ static int netns_identify(int argc, char **argv)
>
>  static int on_netns_del(char *nsname, void *arg)
>  {
> -       char netns_path[MAXPATHLEN];
> +       char netns_path[PATH_MAX];
>
>         snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, nsname);
>         umount2(netns_path, MNT_DETACH);
> @@ -612,7 +611,7 @@ static int netns_add(int argc, char **argv)
>          * userspace tweaks like remounting /sys, or bind mounting
>          * a new /etc/resolv.conf can be shared between uers.
>          */
> -       char netns_path[MAXPATHLEN];
> +       char netns_path[PATH_MAX];
>         const char *name;
>         int fd;
>         int made_netns_run_dir_mount = 0;
> @@ -707,7 +706,7 @@ static int set_netnsid_from_name(const char *name, int nsid)
>
>  static int netns_set(int argc, char **argv)
>  {
> -       char netns_path[MAXPATHLEN];
> +       char netns_path[PATH_MAX];
>         const char *name;
>         int netns, nsid;
>
> diff --git a/lib/namespace.c b/lib/namespace.c
> index c03a103..a61feb6 100644
> --- a/lib/namespace.c
> +++ b/lib/namespace.c
> @@ -9,15 +9,16 @@
>
>  #include <fcntl.h>
>  #include <dirent.h>
> +#include <limits.h>
>
>  #include "utils.h"
>  #include "namespace.h"
>
>  static void bind_etc(const char *name)
>  {
> -       char etc_netns_path[MAXPATHLEN];
> -       char netns_name[MAXPATHLEN];
> -       char etc_name[MAXPATHLEN];
> +       char etc_netns_path[PATH_MAX];
> +       char netns_name[PATH_MAX];
> +       char etc_name[PATH_MAX];
>         struct dirent *entry;
>         DIR *dir;
>
> @@ -43,7 +44,7 @@ static void bind_etc(const char *name)
>
>  int netns_switch(char *name)
>  {
> -       char net_path[MAXPATHLEN];
> +       char net_path[PATH_MAX];
>         int netns;
>
>         snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
> @@ -87,7 +88,7 @@ int netns_switch(char *name)
>
>  int netns_get_fd(const char *name)
>  {
> -       char pathbuf[MAXPATHLEN];
> +       char pathbuf[PATH_MAX];
>         const char *path, *ptr;
>
>         path = name;
> --
> 2.3.6
