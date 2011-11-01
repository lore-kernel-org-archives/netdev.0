From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address filtering
 support for passthru mode
Date: Tue, 01 Nov 2011 05:17:16 -0700
Message-ID: <CAD5315C.386B1%roprabhu@cisco.com>
References: <43F901BD926A4E43B106BF17856F075501A1BD52F6@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A1BD52F6@orsmsx508.amr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 10/31/11 10:39 AM, "Rose, Gregory V" <gregory.v.rose@intel.com> wrote:

>> -----Original Message-----
>> From: Roopa Prabhu [mailto:roprabhu@cisco.com]
>> Sent: Monday, October 31, 2011 10:09 AM
>> To: Rose, Gregory V; netdev@vger.kernel.org
>> Cc: sri@us.ibm.com; dragos.tatulea@gmail.com; kvm@vger.kernel.org;
>> arnd@arndb.de; mst@redhat.com; davem@davemloft.net; mchan@broadcom.com;
>> dwang2@cisco.com; shemminger@vyatta.com; eric.dumazet@gmail.com;
>> kaber@trash.net; benve@cisco.com
>> Subject: Re: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address
>> filtering support for passthru mode
>> 
>> 
>> 
>> 
>> On 10/31/11 9:38 AM, "Rose, Gregory V" <gregory.v.rose@intel.com> wrote:
>> 
>>>> -----Original Message-----
>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org]
>>>> On Behalf Of Roopa Prabhu
>>>> Sent: Friday, October 28, 2011 7:34 PM
>>>> To: netdev@vger.kernel.org
>>>> Cc: sri@us.ibm.com; dragos.tatulea@gmail.com; kvm@vger.kernel.org;
>>>> arnd@arndb.de; mst@redhat.com; davem@davemloft.net; Rose, Gregory V;
>>>> mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
>>>> eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com
>>>> Subject: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address filtering
>>>> support for passthru mode
>>>> 
>>>> v2 -> v3
>>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>>>> - Support for SRIOV VFs.
>>>> [Note: The get filters msg might get too big for SRIOV vfs.
>>>>         But this patch follows existing sriov vf get code and
>>>> accomodate filters for all VF's in a PF.
>>>>         And for the SRIOV case I have only tested the fact that the VF
>>>> arguments are getting delivered to rtnetlink correctly. The rest of
>>>> the code follows existing sriov vf handling code so it should work
>>>> just fine]
>>>> - Fixed all op and netlink attribute names to start with IFLA_RX_FILTER
>>>> - Changed macvlan filter ops to call corresponding lowerdev op if
>> lowerdev
>>>>   supports it for passthru mode. Else it falls back on macvlan handling
>>>> the
>>>>   filters locally as in v1 and v2
>>>> 
>>>> v1 -> v2
>>>> - Instead of TUNSETTXFILTER introduced rtnetlink interface for the same
>>>> 
>>> 
>>> [snip...]
>>> 
>>>> 
>>>> This patch series implements the following
>>>> 01/6 rtnetlink: Netlink interface for setting MAC and VLAN filters
>>>> 02/6 netdev: Add netdev_ops to set and get MAC/VLAN rx filters
>>>> 03/6 rtnetlink: Add support to set MAC/VLAN filters
>>>> 04/6 rtnetlink: Add support to get MAC/VLAN filters
>>>> 05/6 macvlan: Add support to set MAC/VLAN filter netdev ops
>>>> 06/6 macvlan: Add support to get MAC/VLAN filter netdev ops
>>>> 
>>>> Please comment. Thanks.
>>> 
>>> After some preliminary review this looks pretty good to me in so far as
>> adding
>>> the necessary hooks to do what I need to do.  I appreciate your effort
>> on
>>> this.
>>> 
>>> I'm sort of a hands-on type of person so I need to apply this patch to a
>>> private git tree and then take it for a test drive (so to speak).  If I have
>>> further comments I'll get back to you.
>>> 
>> Sounds good.
>> 
>>> Did you have any plans for modifying any user space tools such as 'ip' to
>>> use
>>> this interface?
>>> 
>> 
>> Yes, I have an iproute2 sample patch for setting and displaying the filters
>> which I have been using to test this interface. I can send the patch to you
>> after some cleanup if you think it will be useful for you to try out this
>> interface.
>> 
>> Thanks Greg.
> 
> Yes, please do.
> 
> Thanks,
> 
> - Greg
> 
Greg, here is the patch. I rebased it with tip-of-tree iproute2 git. Thanks.

    iproute2: support for MAC/VLAN filter
    
    This patch is not complete. Its a bit hackish right now.
    I implemented this patch to only test the kernel interface
    without usability in mind.
    
    Limitations:
    - Havent checked corner cases for sriov vfs
    - usage msg needs to be fixed. Its ugly right now
    - vf = -1 for direct assignment of filters on a vf or any network
interface
    - functions could be broken down, var names changed etc
    - show part definately needs to change. It does not
    follow the convention right now
    - it has some redundant code which can be removed and simplified
    
    I will work on this patch some more and resubmit this patch
    after the kernel patch gets accepted.

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 304c44f..ffd03e1 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,8 @@ enum {
     IFLA_AF_SPEC,
     IFLA_GROUP,        /* Group the device belongs to */
     IFLA_NET_NS_FD,
+    IFLA_VF_RX_FILTERS,
+    IFLA_RX_FILTER,
     __IFLA_MAX
 };
 
@@ -264,6 +266,8 @@ enum macvlan_mode {
 
 /* SR-IOV virtual function management section */
 
+#define SELF_VF        -1
+
 enum {
     IFLA_VF_INFO_UNSPEC,
     IFLA_VF_INFO,
@@ -378,4 +382,63 @@ struct ifla_port_vsi {
     __u8 pad[3];
 };
 
+/* VF rx filters management section
+ *
+ *    Nested layout of set/get msg is:
+ *
+ *    [IFLA_VF_RX_FILTERS]
+ *        [IFLA_VF_RX_FILTER]
+ *            [IFLA_RX_FILTER_*], ...
+ *        [IFLA_VF_RX_FILTER]
+ *            [IFLA_RX_FILTER_*], ...
+ *        ...
+ *    [IFLA_RX_FILTER]
+ *        [IFLA_RX_FILTER_*], ...
+ */
+enum {
+    IFLA_VF_RX_FILTER_UNSPEC,
+    IFLA_VF_RX_FILTER,            /* nest */
+    __IFLA_VF_RX_FILTER_MAX,
+};
+
+#define IFLA_VF_RX_FILTER_MAX (__IFLA_VF_RX_FILTER_MAX - 1)
+
+enum {
+    IFLA_RX_FILTER_UNSPEC,
+    IFLA_RX_FILTER_VF,        /* __u32 */
+    IFLA_RX_FILTER_ADDR,
+    IFLA_RX_FILTER_VLAN,
+    __IFLA_RX_FILTER_MAX,
+};
+#define IFLA_RX_FILTER_MAX (__IFLA_RX_FILTER_MAX - 1)
+
+enum {
+    IFLA_RX_FILTER_ADDR_UNSPEC,
+    IFLA_RX_FILTER_ADDR_FLAGS,
+    IFLA_RX_FILTER_ADDR_UC_LIST,
+    IFLA_RX_FILTER_ADDR_MC_LIST,
+    __IFLA_RX_FILTER_ADDR_MAX,
+};
+#define IFLA_RX_FILTER_ADDR_MAX (__IFLA_RX_FILTER_ADDR_MAX - 1)
+
+#define RX_FILTER_FLAGS (IFF_UP | IFF_BROADCAST | IFF_MULTICAST | \
+                IFF_PROMISC | IFF_ALLMULTI)
+
+enum {
+    IFLA_ADDR_LIST_UNSPEC,
+    IFLA_ADDR_LIST_ENTRY,
+    __IFLA_ADDR_LIST_MAX,
+};
+#define IFLA_ADDR_LIST_MAX (__IFLA_ADDR_LIST_MAX - 1)
+
+enum {
+    IFLA_RX_FILTER_VLAN_UNSPEC,
+    IFLA_RX_FILTER_VLAN_BITMAP,
+    __IFLA_RX_FILTER_VLAN_MAX,
+};
+#define IFLA_RX_FILTER_VLAN_MAX (__IFLA_RX_FILTER_VLAN_MAX - 1)
+
+#define VLAN_BITMAP_SPLIT_MAX 8
+#define VLAN_BITMAP_SIZE    (VLAN_N_VID/VLAN_BITMAP_SPLIT_MAX)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 85f05a2..4154b07 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -192,6 +192,120 @@ static void print_linktype(FILE *fp, struct rtattr
*tb)
     }
 }
 
+static void print_vlan_bitmap(FILE *fp, struct rtattr *vlan_bitmap)
+{
+    unsigned long active_vlans[4096/64];
+    int i = 0, j = 0;
+    int first = 1;
+
+    memcpy(active_vlans, RTA_DATA(vlan_bitmap), sizeof(active_vlans));
+
+    for (i = 0 ; i < 64; i++) {
+        for (j = 0; j  < 64; j++) {
+            if (((active_vlans[i] >> j) & 1UL) == 1 ) {
+                if (!first)
+                    fprintf(fp, ",");
+                else
+                    first = 0;
+                  
+                fprintf(fp, "%d", j + 64 * i);
+            }
+        }
+    }
+}
+
+static void print_rx_filter(FILE *fp, struct rtattr *tb)
+{
+    struct rtattr *rx_filter[IFLA_RX_FILTER_MAX+1];
+    int first;
+
+    parse_rtattr_nested(rx_filter, IFLA_RX_FILTER_MAX, tb);
+
+    fprintf(fp, "rx_filter ");
+    if (rx_filter[IFLA_RX_FILTER_VF])
+        fprintf(fp, "vf:%d ",
+        *(unsigned int *)RTA_DATA(rx_filter[IFLA_RX_FILTER_VF]));
+
+    if (rx_filter[IFLA_RX_FILTER_ADDR]) {
+        struct rtattr *rx_addr_filter[IFLA_RX_FILTER_ADDR_MAX+1];
+        unsigned int flags;
+
+        parse_rtattr_nested(rx_addr_filter, IFLA_RX_FILTER_ADDR_MAX,
+                rx_filter[IFLA_RX_FILTER_ADDR]);
+
+        if (rx_addr_filter[IFLA_RX_FILTER_ADDR_FLAGS]) {
+            flags = *(unsigned int *)RTA_DATA(
+                rx_addr_filter[IFLA_RX_FILTER_ADDR_FLAGS]);
+            fprintf(fp, "flags IFF_UP=%s, "
+                "IFF_BROADCAST=%s, "
+                "IFF_MULTICAST=%s, IFF_PROMISC=%s, "
+                "IFF_ALLMULTI=%s ",
+                ((flags & IFF_UP) ? "on" : "off"),
+                ((flags & IFF_BROADCAST) ? "on" : "off"),
+                ((flags & IFF_MULTICAST) ? "on" : "off"),
+                ((flags & IFF_PROMISC) ? "on" : "off"),
+                ((flags & IFF_ALLMULTI) ? "on" : "off"));
+        }
+
+        if (rx_addr_filter[IFLA_RX_FILTER_ADDR_UC_LIST]) {
+            struct rtattr *i;
+            struct rtattr *uclist =
rx_addr_filter[IFLA_RX_FILTER_ADDR_UC_LIST];
+            int rem = RTA_PAYLOAD(uclist);
+            SPRINT_BUF(b1);
+            first = 1;
+            fprintf(fp, " uc ");
+            for (i = RTA_DATA(uclist); RTA_OK(i, rem);
+                i = RTA_NEXT(i, rem)) {
+                if (!first)
+                    fprintf(fp, ",");
+                else
+                    first = 0;
+                fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(i),
+                    RTA_PAYLOAD(i), 0, b1, sizeof(b1)));
+            }
+        }
+
+        if (rx_addr_filter[IFLA_RX_FILTER_ADDR_MC_LIST]) {
+            struct rtattr *i;
+            struct rtattr *mclist =
rx_addr_filter[IFLA_RX_FILTER_ADDR_MC_LIST];
+            SPRINT_BUF(b1);
+            int rem = RTA_PAYLOAD(mclist);
+
+            first = 1;
+            fprintf(fp, " mc ");
+            for (i = RTA_DATA(mclist); RTA_OK(i, rem);
+                i = RTA_NEXT(i, rem)) {
+                if (!first)
+                    fprintf(fp, ",");
+                else
+                    first = 0;
+                fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(i),
+                    RTA_PAYLOAD(i), 0, b1, sizeof(b1)));
+            }
+        }
+    }    
+
+    if (rx_filter[IFLA_RX_FILTER_VLAN]) {
+        struct rtattr *rx_vlan_filter[IFLA_RX_FILTER_VLAN_MAX+1];
+
+        fprintf(fp, " vlans ");
+        parse_rtattr_nested(rx_vlan_filter, IFLA_RX_FILTER_VLAN_MAX,
+                rx_filter[IFLA_RX_FILTER_VLAN]);
+        print_vlan_bitmap(fp,
+                rx_vlan_filter[IFLA_RX_FILTER_VLAN_BITMAP]);
+    }
+    fprintf(fp, "\n");
+}
+
+static void print_vf_rx_filters(FILE *fp, struct rtattr *tb)
+{
+    struct rtattr *i, *vf_filters = tb;
+    int rem = RTA_PAYLOAD(vf_filters);
+
+    for (i = RTA_DATA(vf_filters); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+        print_rx_filter(fp, i);
+}
+
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
     struct ifla_vf_mac *vf_mac;
@@ -319,6 +433,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
     if (do_link && tb[IFLA_LINKINFO] && show_details)
         print_linktype(fp, tb[IFLA_LINKINFO]);
 
+    if (do_link && tb[IFLA_RX_FILTER] ) {
+        fprintf(fp, "\n\t");
+        print_rx_filter(fp, tb[IFLA_RX_FILTER]);
+    }
+
+    if (do_link && tb[IFLA_VF_RX_FILTERS] ) {
+        fprintf(fp, "\n\t");
+        print_vf_rx_filters(fp, tb[IFLA_VF_RX_FILTERS]);
+    }
+
     if (do_link && tb[IFLA_IFALIAS])
         fprintf(fp,"\n    alias %s",
             (const char *) RTA_DATA(tb[IFLA_IFALIAS]));
diff --git a/ip/iplink.c b/ip/iplink.c
index 35e6dc6..42897fb 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -71,7 +71,8 @@ void iplink_usage(void)
     fprintf(stderr, "              [ alias NAME ]\n");
     fprintf(stderr, "                      [ vf NUM [ mac LLADDR ]\n");
     fprintf(stderr, "                   [ vlan VLANID [ qos VLAN-QOS ]
]\n");
-    fprintf(stderr, "                   [ rate TXRATE ] ] \n");
+    fprintf(stderr, "                   [ rate TXRATE ] \n");
+    fprintf(stderr, "                                [ rx_filter [flags
FILTER_FLAGS uc UC_LIST mc MC_LIST] [vlan VLANID_LIST]]\n");
     fprintf(stderr, "              [ master DEVICE ]\n");
     fprintf(stderr, "              [ nomaster ]\n");
     fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
@@ -79,6 +80,10 @@ void iplink_usage(void)
     if (iplink_have_newlink()) {
         fprintf(stderr, "\n");
         fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb |
macvlan | can | bridge }\n");
+        fprintf(stderr, "FILTER_FLAGS := ifup,\n");
+        fprintf(stderr, "UC_LIST := <coma_separated_list_of_unicast
addrs>\n");
+        fprintf(stderr, "MC_LIST := <coma_separated_list_of_multicast
addrs>\n");
+        fprintf(stderr, "VLANID_LIST :=
<coma_separated_list_of_vlanids>\n");
     }
     exit(-1);
 }
@@ -179,55 +184,259 @@ struct iplink_req {
     char            buf[1024];
 };
 
-int iplink_parse_vf(int vf, int *argcp, char ***argvp,
+int
+parse_comma_separated_list(char *argv, int *num_entries, char ***array)
+{
+    char *str = strdup(argv), *tok = NULL;
+    int n = 0;
+    
+    if (!str)
+        return -1;
+
+    for (tok = strtok(str, ","); tok;
+        tok = strtok(NULL, ","), ++n);
+    free(str);
+
+    *array = (char **)malloc(n * sizeof(char *));
+    
+    str = strdup(argv);
+    n = 0;
+    for (tok = strtok(str, ","); tok; tok = strtok(NULL, ","), ++n)
+        (*array)[n] = strdup(tok);
+
+    *num_entries = n;
+
+    return 0;
+}
+
+int iplink_parse_rx_filter(int vf, int *argcp, char ***argvp,
                struct iplink_req *req)
 {
+    int argc = *argcp;
+    char **argv = *argvp;
+    char **mc_list = NULL, **uc_list = NULL, **flags_list = NULL;
+    char **vlan_list = NULL;
+    int i, len;
+    int mc_list_count = 0, uc_list_count = 0, flags_list_count = 0;
+    int vlan_list_count = 0;
+    __u8 mac[32];
+
+    while (NEXT_ARG_OK()) {
+        NEXT_ARG();
+        if (matches(*argv, "rx_filter") == 0) {
+            /* Skip: Hack */
+        }
+        else if (matches(*argv, "flags") == 0) {
+            if (NEXT_ARG_OK()) {
+                NEXT_ARG();
+                parse_comma_separated_list(*argv,
+                    &flags_list_count, &flags_list);
+            }
+        }
+        else if (matches(*argv, "uc") == 0) {
+            if (NEXT_ARG_OK()) {
+                NEXT_ARG();
+                parse_comma_separated_list(*argv,
+                    &uc_list_count, &uc_list);
+            }
+        } else if (matches(*argv, "mc") == 0) {
+            if (NEXT_ARG_OK()) {
+                NEXT_ARG();
+                parse_comma_separated_list(*argv,
+                    &mc_list_count, &mc_list);
+            }
+        } else if (matches(*argv, "vlan") == 0) {
+            if (NEXT_ARG_OK()) {
+                NEXT_ARG();
+                parse_comma_separated_list(*argv,
+                    &vlan_list_count, &vlan_list);
+            }
+        } else {
+            /* rewind arg */
+            PREV_ARG();
+            break;
+        }
+    }
+
+    if (argc == *argcp)
+        incomplete_command();
+
+    if (flags_list || uc_list || mc_list || vlan_list) {
+        struct rtattr *nest_rx_filter = NULL;
+        struct rtattr *nest_vf_filters = NULL;
+
+        if (vf != SELF_VF)
+            nest_vf_filters = addattr_nest(&req->n, sizeof(*req),
+                        IFLA_VF_RX_FILTERS);
+
+
+        if (vf != SELF_VF) {
+            nest_rx_filter = addattr_nest(&req->n, sizeof(*req),
+                        IFLA_VF_RX_FILTER);
+            addattr_l(&req->n, sizeof(*req), IFLA_RX_FILTER_VF,
+                (uint32_t *)&vf, sizeof(uint32_t));
+        }
+        else {
+            nest_rx_filter = addattr_nest(&req->n, sizeof(*req),
+                        IFLA_RX_FILTER);
+        }
+
+        if (flags_list || uc_list || mc_list) {
+            struct rtattr *nest_addr_filter = NULL;
+
+            nest_addr_filter = addattr_nest(&req->n, sizeof(*req),
+                        IFLA_RX_FILTER_ADDR);
+
+            if (flags_list) {
+                unsigned int flags = 0;
+
+                for (i = 0; i < flags_list_count; i++) {
+                    if (!strcmp(flags_list[i], "promisc"))
+                        flags |= IFF_PROMISC;
+                    else if (!strcmp(flags_list[i],
+                        "allmulti"))
+                        flags |= IFF_ALLMULTI;
+                    else if (!strcmp(flags_list[i],
+                        "multicast"))
+                        flags |= IFF_MULTICAST;
+                    else if (!strcmp(flags_list[i],
+                        "broadcast"))
+                        flags |= IFF_BROADCAST;
+                    else if (!strcmp(flags_list[i], "ifup"))
+                        flags |= IFF_UP;
+                }
+        
+                //printf("DEBUG: %s: flags = %x\n",
+                //    __FUNCTION__, flags);
+
+                addattr32(&req->n, sizeof(*req),
+                    IFLA_RX_FILTER_ADDR_FLAGS, flags);
+            }
+    
+            if (uc_list) {
+                struct rtattr *nest_uc_list = NULL;
+
+                nest_uc_list = addattr_nest(&req->n,
+                        sizeof(*req),
+                        IFLA_RX_FILTER_ADDR_UC_LIST);
+                for (i = 0; i < uc_list_count; i++) {
+                    if (!strcmp(uc_list[i], "null"))
+                        continue;
+                    //printf("DEBUG: uc[%d] = %s\n", i, uc_list[i]);
+                    len = ll_addr_a2n((char *)mac, 32,
+                            uc_list[i]);
+                    if (len < 0)
+                         invarg("Invalid \"mac\" value\n", mac);
+                    addattr_l(&req->n, sizeof(*req),
+                        IFLA_ADDR_LIST_ENTRY, mac, 32);
+                }
+                addattr_nest_end(&req->n, nest_uc_list);
+            }
+
+            if (mc_list) {
+                struct rtattr *nest_mc_list = NULL;
+
+                nest_mc_list = addattr_nest(&req->n,
+                        sizeof(*req),
+                        IFLA_RX_FILTER_ADDR_MC_LIST);
+                for (i = 0; i < mc_list_count; i++) {
+                    if (!strcmp(mc_list[i], "null"))
+                        continue;
+                    //printf("DEBUG: mc[%d] = %s\n", i, mc_list[i]);
+                    len = ll_addr_a2n((char *)mac, 32,
+                            mc_list[i]);
+                    if (len < 0)
+                         invarg("Invalid \"mac\" value\n", mac);
+                    addattr_l(&req->n, sizeof(*req),
+                        IFLA_ADDR_LIST_ENTRY, mac, 32);
+                }
+                addattr_nest_end(&req->n, nest_mc_list);
+            }
+            addattr_nest_end(&req->n, nest_addr_filter);
+        }
+
+        if (vlan_list) {
+            struct rtattr *nest_vlans = NULL;
+            unsigned long arg_vlans[4096/64];
+
+            memset(arg_vlans, 0, 512);
+            for (i = 0; i < vlan_list_count; i++)
+                arg_vlans[atoi(vlan_list[i])/64] |=
+                    1UL << (atoi(vlan_list[i])%64);
+
+            nest_vlans = addattr_nest(&req->n, sizeof(*req),
+                    IFLA_RX_FILTER_VLAN);
+            addattr_l(&req->n, sizeof(*req),
+                IFLA_RX_FILTER_VLAN_BITMAP,
+                arg_vlans, sizeof(arg_vlans));
+            addattr_nest_end(&req->n, nest_vlans);
+        }
+
+        addattr_nest_end(&req->n, nest_rx_filter);
+        if (nest_vf_filters)
+            addattr_nest_end(&req->n, nest_vf_filters);
+
+        if (flags_list) {
+            for (i = 0; i < flags_list_count; i++)
+                free(flags_list[i]);
+            free(flags_list);
+        }
+        if (uc_list) {
+            for (i = 0; i < uc_list_count; i++)
+                free(uc_list[i]);
+            free(uc_list);
+        }
+        if (mc_list) {
+            for (i = 0; i < mc_list_count; i++)
+                free(mc_list[i]);
+            free(mc_list);
+        }
+    }
+
+    *argcp = argc;
+    *argvp = argv;
+
+    return 0;
+}
+
+int iplink_parse_vf(int vf, int *argcp, char ***argvp,
+             struct iplink_req *req)
+{
     int len, argc = *argcp;
     char **argv = *argvp;
+    struct rtattr *vflist;
     struct rtattr *vfinfo;
-
-    vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
+    char *mac = NULL;
+    char *vlan = NULL;
+    char *qos = NULL;
+    char *rate = NULL;
+    struct ifla_vf_mac ivm = { .vf = vf, };
+    struct ifla_vf_vlan ivv = { .vf = vf, .qos = 0, };
+    struct ifla_vf_tx_rate ivt = { .vf = vf, };
 
     while (NEXT_ARG_OK()) {
         NEXT_ARG();
-        if (matches(*argv, "mac") == 0) {
-            struct ifla_vf_mac ivm;
+        if (matches(*argv, "rx_filter") == 0) {
+            iplink_parse_rx_filter(vf, &argc, &argv, req);
+        } else if (matches(*argv, "mac") == 0) {
             NEXT_ARG();
-            ivm.vf = vf;
-            len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
-            if (len < 0)
-                return -1;
-            addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm,
sizeof(ivm));
+            mac = *argv;
         } else if (matches(*argv, "vlan") == 0) {
-            struct ifla_vf_vlan ivv;
             NEXT_ARG();
-            if (get_unsigned(&ivv.vlan, *argv, 0)) {
-                invarg("Invalid \"vlan\" value\n", *argv);
-            }
-            ivv.vf = vf;
-            ivv.qos = 0;
+            vlan = *argv;
             if (NEXT_ARG_OK()) {
                 NEXT_ARG();
                 if (matches(*argv, "qos") == 0) {
                     NEXT_ARG();
-                    if (get_unsigned(&ivv.qos, *argv, 0)) {
-                        invarg("Invalid \"qos\" value\n", *argv);
-                    }
+                    qos = *argv;
                 } else {
                     /* rewind arg */
                     PREV_ARG();
                 }
             }
-            addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv,
sizeof(ivv));
         } else if (matches(*argv, "rate") == 0) {
-            struct ifla_vf_tx_rate ivt;
             NEXT_ARG();
-            if (get_unsigned(&ivt.rate, *argv, 0)) {
-                invarg("Invalid \"rate\" value\n", *argv);
-            }
-            ivt.vf = vf;
-            addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt,
sizeof(ivt));
-        
+            rate = *argv;
         } else {
             /* rewind arg */
             PREV_ARG();
@@ -238,14 +447,46 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
     if (argc == *argcp)
         incomplete_command();
 
-    addattr_nest_end(&req->n, vfinfo);
+    if (mac || vlan || rate) {
+
+        vflist = addattr_nest(&req->n, sizeof(*req), IFLA_VFINFO_LIST);
+        vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
+
+        if (mac) {
+            len = ll_addr_a2n((char *)ivm.mac, 32, mac);
+            if (len < 0)
+                invarg("Invalid \"mac\" value\n", mac);
+            addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC,
+                &ivm, sizeof(ivm));
+        }
+
+        if (vlan) {
+            if (get_unsigned(&ivv.vlan, vlan, 0))
+                invarg("Invalid \"vlan\" value\n", vlan);
+            if (qos) {
+                if (get_unsigned(&ivv.qos, qos, 0))
+                    invarg("Invalid \"qos\" value\n", qos);
+            }
+            addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN,
+                &ivv, sizeof(ivv));
+        }
+
+        if (rate) {
+            if (get_unsigned(&ivt.rate, rate, 0))
+                invarg("Invalid \"rate\" value\n", rate);
+            addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE,
+                &ivt, sizeof(ivt));
+        }
+
+        addattr_nest_end(&req->n, vfinfo);
+        addattr_nest_end(&req->n, vflist);
+    }
 
     *argcp = argc;
     *argvp = argv;
     return 0;
 }
 
-
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
         char **name, char **type, char **link, char **dev, int *group)
 {
@@ -362,12 +603,9 @@ int iplink_parse(int argc, char **argv, struct
iplink_req *req,
             if (get_integer(&vf,  *argv, 0)) {
                 invarg("Invalid \"vf\" value\n", *argv);
             }
-            vflist = addattr_nest(&req->n, sizeof(*req),
-                          IFLA_VFINFO_LIST);
             len = iplink_parse_vf(vf, &argc, &argv, req);
             if (len < 0)
                 return -1;
-            addattr_nest_end(&req->n, vflist);
         } else if (matches(*argv, "master") == 0) {
             int ifindex;
             NEXT_ARG();

