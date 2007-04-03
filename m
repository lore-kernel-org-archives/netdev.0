From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] net: cleanup extra semicolons
Date: Tue, 3 Apr 2007 12:00:09 -0700
Message-ID: <20070403120009.4f3b41b7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37009 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422655AbXDCTAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 15:00:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spring cleaning time...

There seems to be a lot of places in the network code that have
extra bogus semicolons after conditionals.  Most commonly is a
bogus semicolon after: switch() { }

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/802/tr.c             |    3 ++-
 net/8021q/vlan.c         |    6 +++---
 net/8021q/vlan_dev.c     |    4 ++--
 net/ax25/ax25_ip.c       |    2 +-
 net/bluetooth/hci_core.c |    4 ++--
 net/bluetooth/sco.c      |    2 +-
 net/core/link_watch.c    |    2 +-
 net/core/pktgen.c        |    6 +++---
 net/core/rtnetlink.c     |    2 +-
 net/core/skbuff.c        |    2 +-
 net/ipv4/fib_semantics.c |    2 +-
 net/ipv4/ipconfig.c      |    4 ++--
 net/ipv4/multipath_drr.c |    2 +-
 net/ipv4/tcp.c           |    7 ++++---
 net/ipv4/tcp_input.c     |    9 +++++----
 net/ipv4/xfrm4_policy.c  |    2 +-
 net/ipv6/addrconf.c      |    4 ++--
 net/ipv6/datagram.c      |    2 +-
 net/ipv6/exthdrs.c       |    2 +-
 net/ipv6/icmp.c          |    5 +++--
 net/ipv6/ndisc.c         |    2 +-
 net/ipv6/raw.c           |   14 ++++++++------
 net/ipv6/route.c         |    2 +-
 net/ipv6/xfrm6_policy.c  |    5 +++--
 net/irda/af_irda.c       |    4 ++--
 net/iucv/af_iucv.c       |    2 +-
 net/key/af_key.c         |    2 +-
 net/sched/cls_u32.c      |    2 +-
 net/sched/sch_dsmark.c   |    6 +++---
 net/sched/sch_ingress.c  |    4 ++--
 net/sched/sch_prio.c     |    2 +-
 net/sctp/associola.c     |    2 +-
 net/sctp/debug.c         |    5 +++--
 net/sctp/ipv6.c          |    2 +-
 net/sctp/output.c        |    2 +-
 net/sctp/outqueue.c      |   12 ++++++------
 net/sctp/sm_make_chunk.c |    4 ++--
 net/sctp/sm_sideeffect.c |    5 +++--
 net/sctp/sm_statefuns.c  |   10 +++++-----
 net/sctp/sm_statetable.c |    2 +-
 net/sctp/socket.c        |   11 ++++++-----
 net/sctp/transport.c     |    2 +-
 net/sctp/ulpqueue.c      |    8 ++++----
 net/tipc/link.c          |    2 +-
 net/xfrm/xfrm_policy.c   |    2 +-
 net/xfrm/xfrm_state.c    |    8 ++++----
 net/xfrm/xfrm_user.c     |   22 +++++++++++-----------
 47 files changed, 113 insertions(+), 103 deletions(-)

diff --git a/net/802/tr.c b/net/802/tr.c
index eb2de0d..0ba1946 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -554,7 +554,8 @@ static int rif_seq_show(struct seq_file *seq, void *v)
 					if(j==1) {
 						segment=ntohs(entry->rseg[j-1])>>4;
 						seq_printf(seq,"  %03X",segment);
-					};
+					}
+
 					segment=ntohs(entry->rseg[j])>>4;
 					brdgnmb=ntohs(entry->rseg[j-1])&0x00f;
 					seq_printf(seq,"-%01X-%03X",brdgnmb,segment);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index eb1c71e..c0c7bb8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -470,7 +470,7 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 		 */
 	default:
 		snprintf(name, IFNAMSIZ, "vlan%.4i", VLAN_ID);
-	};
+	}
 
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
 			       vlan_setup);
@@ -685,7 +685,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 				break;
 		}
 		break;
-	};
+	}
 
 out:
 	return NOTIFY_DONE;
@@ -819,7 +819,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
 			__FUNCTION__, args.cmd);
 		return -EINVAL;
-	};
+	}
 out:
 	return err;
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9f4cfd0..9c85785 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -66,7 +66,7 @@ int vlan_dev_rebuild_header(struct sk_buff *skb)
 
 		memcpy(veth->h_source, dev->dev_addr, ETH_ALEN);
 		break;
-	};
+	}
 
 	return 0;
 }
@@ -219,7 +219,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		break;
 	default:
 		break;
-	};
+	}
 
 	/*  Was a VLAN packet, grab the encapsulated protocol, which the layer
 	 * three protocols care about.
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 4d4ef35..930e491 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -121,7 +121,7 @@ int ax25_rebuild_header(struct sk_buff *skb)
 		digipeat = route->digipeat;
 		dev = route->dev;
 		ip_mode = route->ip_mode;
-	};
+	}
 
 	if (dev == NULL)
 		dev = skb->dev;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index c177e75..aa4b56a 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -149,7 +149,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 	default:
 		err = -ETIMEDOUT;
 		break;
-	};
+	}
 
 	hdev->req_status = hdev->req_result = 0;
 
@@ -1388,7 +1388,7 @@ static void hci_rx_task(unsigned long arg)
 			case HCI_SCODATA_PKT:
 				kfree_skb(skb);
 				continue;
-			};
+			}
 		}
 
 		/* Process frame */
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index ae43914..3f5163e 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -393,7 +393,7 @@ static void sco_sock_close(struct sock *sk)
 	default:
 		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
-	};
+	}
 
 	release_sock(sk);
 
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 8b45c9d..e3c26a9 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -79,7 +79,7 @@ static void rfc2863_policy(struct net_device *dev)
 	case IF_LINK_MODE_DEFAULT:
 	default:
 		break;
-	};
+	}
 
 	dev->operstate = operstate;
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 7cd0dd6..e04964f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -785,7 +785,7 @@ static int count_trail_chars(const char __user * user_buffer,
 			break;
 		default:
 			goto done;
-		};
+		}
 	}
 done:
 	return i;
@@ -828,7 +828,7 @@ static int strn_len(const char __user * user_buffer, unsigned int maxlen)
 			break;
 		default:
 			break;
-		};
+		}
 	}
 done_str:
 	return i;
@@ -1905,7 +1905,7 @@ static int pktgen_device_event(struct notifier_block *unused,
 	case NETDEV_UNREGISTER:
 		pktgen_mark_device(dev->name);
 		break;
-	};
+	}
 
 	return NOTIFY_DONE;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 91d37eb..26b1ff6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -399,7 +399,7 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 		    operstate == IF_OPER_UNKNOWN)
 			operstate = IF_OPER_DORMANT;
 		break;
-	};
+	}
 
 	if (dev->operstate != operstate) {
 		write_lock_bh(&dev_base_lock);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e60864e..999fd50 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -360,7 +360,7 @@ void kfree_skbmem(struct sk_buff *skb)
 		if (atomic_dec_and_test(fclone_ref))
 			kmem_cache_free(skbuff_fclone_cache, other);
 		break;
-	};
+	}
 }
 
 /**
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3dad12e..406ea70 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -927,7 +927,7 @@ int fib_semantic_match(struct list_head *head, const struct flowi *flp,
 			default:
 				printk(KERN_DEBUG "impossible 102\n");
 				return -EINVAL;
-			};
+			}
 		}
 		return err;
 	}
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 4e19ee0..597c800 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -939,7 +939,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 					if (opt[1] >= 4)
 						memcpy(&server_id, opt + 2, 4);
 					break;
-				};
+				}
 			}
 
 #ifdef IPCONFIG_DEBUG
@@ -984,7 +984,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				ic_myaddr = NONE;
 				ic_servaddr = NONE;
 				goto drop_unlock;
-			};
+			}
 
 			ic_dhcp_msgtype = mt;
 
diff --git a/net/ipv4/multipath_drr.c b/net/ipv4/multipath_drr.c
index 574c735..b03c5ca 100644
--- a/net/ipv4/multipath_drr.c
+++ b/net/ipv4/multipath_drr.c
@@ -100,7 +100,7 @@ static int drr_dev_event(struct notifier_block *this,
 
 		spin_unlock_bh(&state_lock);
 		break;
-	};
+	}
 
 	return NOTIFY_DONE;
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb9d91a..4664733 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -444,7 +444,7 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		break;
 	default:
 		return -ENOIOCTLCMD;
-	};
+	}
 
 	return put_user(answ, (int __user *)arg);
 }
@@ -1954,7 +1954,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	default:
 		err = -ENOPROTOOPT;
 		break;
-	};
+	}
+
 	release_sock(sk);
 	return err;
 }
@@ -2124,7 +2125,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		return 0;
 	default:
 		return -ENOPROTOOPT;
-	};
+	}
 
 	if (put_user(len, optlen))
 		return -EFAULT;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fee6406..38b7ff1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2880,7 +2880,7 @@ static int tcp_process_frto(struct sock *sk, u32 prior_snd_una, int flag)
 		default:
 			tcp_ratehalving_spur_to_response(sk);
 			break;
-		};
+		}
 		tp->frto_counter = 0;
 	}
 	return 0;
@@ -3091,10 +3091,11 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 					 */
 					break;
 #endif
-				};
+				}
+
 				ptr+=opsize-2;
 				length-=opsize;
-		};
+		}
 	}
 }
 
@@ -3300,7 +3301,7 @@ static void tcp_fin(struct sk_buff *skb, struct sock *sk, struct tcphdr *th)
 			printk(KERN_ERR "%s: Impossible, sk->sk_state=%d\n",
 			       __FUNCTION__, sk->sk_state);
 			break;
-	};
+	}
 
 	/* It _is_ possible, that we have something out-of-order _after_ FIN.
 	 * Probably, we should reset in this case. For now drop them.
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index f1c32ff..4ff8ed3 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -263,7 +263,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl)
 		default:
 			fl->fl_ipsec_spi = 0;
 			break;
-		};
+		}
 	}
 	fl->proto = iph->protocol;
 	fl->fl4_dst = iph->daddr;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47d3adf..a52b733 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2283,7 +2283,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		default:
 			addrconf_dev_config(dev);
 			break;
-		};
+		}
 		if (idev) {
 			if (run_pending)
 				addrconf_dad_run(idev);
@@ -2336,7 +2336,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		}
 #endif
 		break;
-	};
+	}
 
 	return NOTIFY_OK;
 }
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4a355fe..403eee6 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -723,7 +723,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				       cmsg->cmsg_type);
 			err = -EINVAL;
 			break;
-		};
+		}
 	}
 
 exit_f:
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index bcb67f8..93f83a4 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -130,7 +130,7 @@ static int ip6_tlvopt_unknown(struct sk_buff **skbp, int optoff)
 	case 2: /* send ICMP PARM PROB regardless and drop packet */
 		icmpv6_param_prob(skb, ICMPV6_UNK_OPTION, optoff);
 		return 0;
-	};
+	}
 
 	kfree_skb(skb);
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index e94992a..e9bcce9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -732,7 +732,8 @@ static int icmpv6_rcv(struct sk_buff **pskb)
 		 */
 
 		icmpv6_notify(skb, type, hdr->icmp6_code, hdr->icmp6_mtu);
-	};
+	}
+
 	kfree_skb(skb);
 	return 0;
 
@@ -865,7 +866,7 @@ int icmpv6_err_convert(int type, int code, int *err)
 	case ICMPV6_TIME_EXCEED:
 		*err = EHOSTUNREACH;
 		break;
-	};
+	}
 
 	return fatal;
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b1cf708..4ee1216 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1630,7 +1630,7 @@ int ndisc_rcv(struct sk_buff *skb)
 	case NDISC_REDIRECT:
 		ndisc_redirect_rcv(skb);
 		break;
-	};
+	}
 
 	return 0;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 9592930..9786a37 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -888,7 +888,7 @@ static int rawv6_seticmpfilter(struct sock *sk, int level, int optname,
 		return 0;
 	default:
 		return -ENOPROTOOPT;
-	};
+	}
 
 	return 0;
 }
@@ -913,7 +913,7 @@ static int rawv6_geticmpfilter(struct sock *sk, int level, int optname,
 		return 0;
 	default:
 		return -ENOPROTOOPT;
-	};
+	}
 
 	return 0;
 }
@@ -967,7 +967,8 @@ static int rawv6_setsockopt(struct sock *sk, int level, int optname,
 		default:
 			return ipv6_setsockopt(sk, level, optname, optval,
 					       optlen);
-	};
+	}
+
 	return do_rawv6_setsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -988,7 +989,7 @@ static int compat_rawv6_setsockopt(struct sock *sk, int level, int optname,
 	default:
 		return compat_ipv6_setsockopt(sk, level, optname,
 					      optval, optlen);
-	};
+	}
 	return do_rawv6_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -1041,7 +1042,8 @@ static int rawv6_getsockopt(struct sock *sk, int level, int optname,
 		default:
 			return ipv6_getsockopt(sk, level, optname, optval,
 					       optlen);
-	};
+	}
+
 	return do_rawv6_getsockopt(sk, level, optname, optval, optlen);
 }
 
@@ -1062,7 +1064,7 @@ static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
 	default:
 		return compat_ipv6_getsockopt(sk, level, optname,
 					      optval, optlen);
-	};
+	}
 	return do_rawv6_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 53d79ac..8a89b41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1769,7 +1769,7 @@ int ipv6_route_ioctl(unsigned int cmd, void __user *arg)
 		rtnl_unlock();
 
 		return err;
-	};
+	}
 
 	return -EINVAL;
 }
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ef746d4..1faa2ea 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -240,7 +240,8 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		if (!afinfo) {
 			dst = *dst_p;
 			goto error;
-		};
+		}
+
 		dst_prev->output = afinfo->output;
 		xfrm_state_put_afinfo(afinfo);
 		/* Sheit... I remember I did this right. Apparently,
@@ -337,7 +338,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl)
 			fl->fl_ipsec_spi = 0;
 			fl->proto = nexthdr;
 			return;
-		};
+		}
 	}
 }
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index f9b15d4..bf39842 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -221,7 +221,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 		break;
 	default:
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
-	};
+	}
 
 	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __FUNCTION__,
 		   self->max_data_size);
@@ -284,7 +284,7 @@ static void irda_connect_indication(void *instance, void *sap,
 		break;
 	default:
 		self->max_data_size = irttp_get_max_seg_size(self->tsap);
-	};
+	}
 
 	IRDA_DEBUG(2, "%s(), max_data_size=%d\n", __FUNCTION__,
 		   self->max_data_size);
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 5563288..e84c924 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -181,7 +181,7 @@ static void iucv_sock_close(struct sock *sk)
 	default:
 		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
-	};
+	}
 
 	release_sock(sk);
 	iucv_sock_kill(sk);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 90deefe..850a7e4 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -379,7 +379,7 @@ static int verify_address_len(void *p)
 		 */
 		return -EINVAL;
 		break;
-	};
+	}
 
 	return 0;
 }
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 62e1deb..c7a347b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -436,7 +436,7 @@ static void u32_destroy(struct tcf_proto *tp)
 			BUG_TRAP(ht->refcnt == 0);
 
 			kfree(ht);
-		};
+		}
 
 		kfree(tp_c);
 	}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index e38e0d0..3c6fd18 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -226,7 +226,7 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 			default:
 				skb->tc_index = 0;
 				break;
-		};
+		}
 	}
 
 	if (TC_H_MAJ(skb->priority) == sch->handle)
@@ -257,7 +257,7 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 				if (p->default_index != NO_DEFAULT_INDEX)
 					skb->tc_index = p->default_index;
 				break;
-		};
+		}
 	}
 
 	err = p->q->enqueue(skb,p->q);
@@ -310,7 +310,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 				       "unsupported protocol %d\n",
 				       ntohs(skb->protocol));
 			break;
-	};
+	}
 
 	return skb;
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 1fb60ab..581bd38 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -170,7 +170,7 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 			skb->tc_index = TC_H_MIN(res.classid);
 			result = TC_ACT_OK;
 			break;
-	};
+	}
 /* backward compat */
 #else
 #ifdef	CONFIG_NET_CLS_POLICE
@@ -187,7 +187,7 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		sch->bstats.bytes += skb->len;
 		result = NF_ACCEPT;
 		break;
-	};
+	}
 
 #else
 	D2PRINTK("Overriding result to ACCEPT\n");
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 5cfe60b..269a6e1 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -62,7 +62,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			*qerr = NET_XMIT_SUCCESS;
 		case TC_ACT_SHOT:
 			return NULL;
-		};
+		}
 
 		if (!q->filter_list ) {
 #else
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 37a343e..db73ef9 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -733,7 +733,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 
 	default:
 		return;
-	};
+	}
 
 	/* Generate and send a SCTP_PEER_ADDR_CHANGE notification to the
 	 * user.
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 5f5ab28..e8c0f74 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -93,8 +93,9 @@ const char *sctp_cname(const sctp_subtype_t cid)
 		return "FWD_TSN";
 
 	default:
-		return "unknown chunk";
-	};
+		break;
+	}
+
 	return "unknown chunk";
 }
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 5b0cdda..ca527a2 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -604,7 +604,7 @@ static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
 	default:
 		retval = SCTP_SCOPE_GLOBAL;
 		break;
-	};
+	}
 
 	return retval;
 }
diff --git a/net/sctp/output.c b/net/sctp/output.c
index f875fc3..d85543d 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -176,7 +176,7 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	case SCTP_XMIT_OK:
 	case SCTP_XMIT_NAGLE_DELAY:
 		break;
-	};
+	}
 
 	return retval;
 }
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 41abfd1..992f361 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -338,7 +338,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 				SCTP_INC_STATS(SCTP_MIB_OUTORDERCHUNKS);
 			q->empty = 0;
 			break;
-		};
+		}
 	} else {
 		list_add_tail(&chunk->list, &q->control_chunk_list);
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
@@ -630,7 +630,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			/* Retrieve a new chunk to bundle. */
 			lchunk = sctp_list_dequeue(lqueue);
 			break;
-		};
+		}
 
 		/* If we are here due to a retransmit timeout or a fast
 		 * retransmit and if there are any chunks left in the retransmit
@@ -779,7 +779,7 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		default:
 			/* We built a chunk with an illegal type! */
 			BUG();
-		};
+		}
 	}
 
 	/* Is it OK to send data chunks?  */
@@ -1397,7 +1397,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				SCTP_DEBUG_PRINTK("ACKed: %08x", tsn);
 				dbg_prt_state = 0;
 				dbg_ack_tsn = tsn;
-			};
+			}
 
 			dbg_last_ack_tsn = tsn;
 #endif /* SCTP_DEBUG */
@@ -1452,7 +1452,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				SCTP_DEBUG_PRINTK("KEPT: %08x",tsn);
 				dbg_prt_state = 1;
 				dbg_kept_tsn = tsn;
-			};
+			}
 
 			dbg_last_kept_tsn = tsn;
 #endif /* SCTP_DEBUG */
@@ -1476,7 +1476,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 		} else {
 			SCTP_DEBUG_PRINTK("\n");
 		}
-	};
+	}
 #endif /* SCTP_DEBUG */
 	if (transport) {
 		if (bytes_acked) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 759ea3d..be783a3 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2077,7 +2077,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 
 			default: /* Just ignore anything else.  */
 				break;
-			};
+			}
 		}
 		break;
 
@@ -2118,7 +2118,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 		SCTP_DEBUG_PRINTK("Ignoring param: %d for association %p.\n",
 				  ntohs(param.p->type), asoc);
 		break;
-	};
+	}
 
 	return retval;
 }
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 0a1a197..b37a7ad 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1009,7 +1009,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 		       status, state, event_type, subtype.chunk);
 		BUG();
 		break;
-	};
+	}
 
 bail:
 	return error;
@@ -1489,7 +1489,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
 			       cmd->verb, cmd->obj.ptr);
 			break;
-		};
+		}
+
 		if (error)
 			break;
 	}
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index e0ec16d..9e28a5d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -629,7 +629,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
 		case -SCTP_IERROR_BAD_SIG:
 		default:
 			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
-		};
+		}
 	}
 
 
@@ -1195,7 +1195,7 @@ static void sctp_tietags_populate(struct sctp_association *new_asoc,
 		new_asoc->c.my_ttag   = asoc->c.my_vtag;
 		new_asoc->c.peer_ttag = asoc->c.peer_vtag;
 		break;
-	};
+	}
 
 	/* Other parameters for the endpoint SHOULD be copied from the
 	 * existing parameters of the association (e.g. number of
@@ -1904,7 +1904,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(const struct sctp_endpoint *ep,
 		case -SCTP_IERROR_BAD_SIG:
 		default:
 			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
-		};
+		}
 	}
 
 	/* Compare the tie_tag in cookie with the verification tag of
@@ -1936,7 +1936,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(const struct sctp_endpoint *ep,
 	default: /* Discard packet for all others. */
 		retval = sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 		break;
-	};
+	}
 
 	/* Delete the tempory new association. */
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
@@ -4816,7 +4816,7 @@ sctp_disposition_t sctp_sf_t2_timer_expire(const struct sctp_endpoint *ep,
 	default:
 		BUG();
 		break;
-	};
+	}
 
 	if (!reply)
 		goto nomem;
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 5e54b17..523071c 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -101,7 +101,7 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 	default:
 		/* Yikes!  We got an illegal event type.  */
 		return &bug;
-	};
+	}
 }
 
 #define TYPE_SCTP_FUNC(func) {.fn = func, .name = #func}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e5b9f49..77f5637 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -935,7 +935,7 @@ SCTP_STATIC int sctp_setsockopt_bindx(struct sock* sk,
 	default:
 		err = -EINVAL;
 		break;
-	};
+	}
 
 out:
 	kfree(kaddrs);
@@ -3042,7 +3042,7 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-	};
+	}
 
 	sctp_release_sock(sk);
 
@@ -4867,7 +4867,7 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-	};
+	}
 
 	sctp_release_sock(sk);
 	return retval;
@@ -5192,7 +5192,8 @@ int sctp_inet_listen(struct socket *sock, int backlog)
 		break;
 	default:
 		break;
-	};
+	}
+
 	if (err)
 		goto cleanup;
 
@@ -5455,7 +5456,7 @@ SCTP_STATIC int sctp_msghdr_parse(const struct msghdr *msg,
 
 		default:
 			return -EINVAL;
-		};
+		}
 	}
 	return 0;
 }
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 4d8c2ab..961df27 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -507,7 +507,7 @@ void sctp_transport_lower_cwnd(struct sctp_transport *transport,
 			transport->cwnd = max(transport->cwnd/2,
 						 4*transport->asoc->pathmtu);
 		break;
-	};
+	}
 
 	transport->partial_bytes_acked = 0;
 	SCTP_DEBUG_PRINTK("%s: transport: %p reason: %d cwnd: "
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index ae374a9..e2f3c5f 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -385,7 +385,7 @@ static struct sctp_ulpevent *sctp_make_reassembled_event(struct sk_buff_head *qu
 			break;
 		pos->next = pnext;
 		pos = pnext;
-	};
+	}
 
 	event = sctp_skb2event(f_frag);
 	SCTP_INC_STATS(SCTP_MIB_REASMUSRMSGS);
@@ -470,7 +470,7 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_u
 			else
 				first_frag = NULL;
 			break;
-		};
+		}
 	}
 
 	asoc = ulpq->asoc;
@@ -550,7 +550,7 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_partial(struct sctp_ulpq
 			goto done;
 		default:
 			return NULL;
-		};
+		}
 	}
 
 	/* We have the reassembled event. There is no need to look
@@ -642,7 +642,7 @@ static inline struct sctp_ulpevent *sctp_ulpq_retrieve_first(struct sctp_ulpq *u
 			break;
 		default:
 			return NULL;
-		};
+		}
 	}
 
 	/* We have the reassembled event. There is no need to look
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 71c2f2f..c27a7bd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2569,7 +2569,7 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 		if (obuf == NULL) {
 			warn("Link unable to unbundle message(s)\n");
 			break;
-		};
+		}
 		pos += align(msg_size(buf_msg(obuf)));
 		msg_dbg(buf_msg(obuf), "     /");
 		tipc_net_route_msg(obuf);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1942575..7629260 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1049,7 +1049,7 @@ static inline int policy_to_flow_dir(int dir)
 		return FLOW_DIR_OUT;
 	case XFRM_POLICY_FWD:
 		return FLOW_DIR_FWD;
-	};
+	}
 }
 
 static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a237dfd..ffec7a5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -458,7 +458,7 @@ static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi,
 					     x->id.daddr.a6))
 				continue;
 			break;
-		};
+		}
 
 		xfrm_state_hold(x);
 		return x;
@@ -493,7 +493,7 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm
 					     x->props.saddr.a6))
 				continue;
 			break;
-		};
+		}
 
 		xfrm_state_hold(x);
 		return x;
@@ -722,7 +722,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 					     (struct in6_addr *)saddr))
 				continue;
 			break;
-		};
+		}
 
 		xfrm_state_hold(x);
 		return x;
@@ -755,7 +755,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 			ipv6_addr_copy((struct in6_addr *)x->id.daddr.a6,
 				       (struct in6_addr *)daddr);
 			break;
-		};
+		}
 
 		x->km.state = XFRM_STATE_ACQ;
 		x->id.proto = proto;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2f6671f..a9b01e2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -71,7 +71,7 @@ static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
 	return 0;
@@ -152,7 +152,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 
 	default:
 		goto out;
-	};
+	}
 
 	err = -EINVAL;
 	switch (p->id.proto) {
@@ -192,7 +192,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 
 	default:
 		goto out;
-	};
+	}
 
 	if ((err = verify_one_alg(xfrma, XFRMA_ALG_AUTH)))
 		goto out;
@@ -217,7 +217,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 
 	default:
 		goto out;
-	};
+	}
 
 	err = 0;
 
@@ -712,7 +712,7 @@ static int verify_userspi_info(struct xfrm_userspi_info *p)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	if (p->min > p->max)
 		return -EINVAL;
@@ -790,7 +790,7 @@ static int verify_policy_dir(u8 dir)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	return 0;
 }
@@ -806,7 +806,7 @@ static int verify_policy_type(u8 type)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	return 0;
 }
@@ -822,7 +822,7 @@ static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	switch (p->action) {
 	case XFRM_POLICY_ALLOW:
@@ -831,7 +831,7 @@ static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	switch (p->sel.family) {
 	case AF_INET:
@@ -846,7 +846,7 @@ static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	return verify_policy_dir(p->dir);
 }
@@ -913,7 +913,7 @@ static int validate_tmpl(int nr, struct xfrm_user_tmpl *ut, u16 family)
 #endif
 		default:
 			return -EINVAL;
-		};
+		}
 	}
 
 	return 0;
-- 
1.4.4.2

